#
# Manages installing/removing/reading/etc snips from various snip::repos
#
class Snip::Manager
  include IndifferentVariableHash

  attr_accessor :search_repos, :install_repo

  def initialize install_directory=nil, *search_directories
    set_defaults
    load_config

    self.install_path = install_directory if install_directory
    self.search_path  = search_directories.join(self.path_seperator) unless search_directories.empty?
    
    search_paths.each { |path| 
      self.search_repos << Snip::Repo.new(path)
      self.install_repo = self.search_repos.last if path == self.install_path
    }
    self.install_repo ||= Snip::Repo.new( self.install_path )
  end

  def set_defaults
    self.variables      ||= {}
    self.path_seperator   = '$' 
    self.rc_file          = ENV['SNIP_RC']    || '~/.sniprc'
    self.search_path      = ENV['SNIP_PATH']  || 'http://snips.code-snips.org' 
    self.install_path     = ENV['SNIP_REPO']  || '~/.snips'

    self.search_repos = []
  end

  # to help define commands in ~/.sniprc
  def self.commands &block
    unless block.nil?
      require 'snips/bin'
      bin = Snip::Bin
      bin.instance_eval &block
    end 
  end 

  def load_config
    rc = File.expand_path self.rc_file
    eval File.read(rc) if File.file?rc
  end

  def search_paths
    paths = self.search_path.split( self.path_seperator ).map{ |path| path.strip }.select { |path| not path.empty? }.uniq
    paths = [ self.install_path ] + paths unless paths.include? self.install_path
    paths || []
  end

  def all_repos
    ( self.search_repos << self.install_repo ).uniq
  end
  alias repos all_repos

  def snip name_or_matcher
    first_found = nil
    all_repos.find{ |repo| first_found = repo.snip(name_or_matcher) }
    first_found
  end
  def snips *names_or_matchers
    all_repos.inject([]){ |all,repo| all + repo.snips(*names_or_matchers) }.uniq
  end
  def all_snips
    all_repos.inject([]){ |all,repo| all + repo.all_snips }.uniq
  end
  def current_snips
    all_repos.inject([]){ |all,repo| all + repo.current_snips }.uniq
  end

  def list
    all_repos.inject(''){ |all,repo| 
      all << "\n**** #{ repo.location } ****\n#{ repo.list }" if repo.current_snips.length > 0
      all
    } + "\n"
  end

  def search *options
    all_repos.inject([]){ |all,repo| all + repo.search(*options) }.uniq
  end
  
  def find_first_snip_and_repo name_or_matcher
    name_or_matcher = name_or_matcher.name if name_or_matcher.is_a?Snip
    found_snip, found_repo = nil, nil
    all_repos.find{ |repo| 
      found_snip = repo.snip( name_or_matcher ) 
      found_repo = repo if found_snip
      found_snip
    }
    return found_snip, found_repo
  end

  def which snip
    snip, repo = find_first_snip_and_repo snip
    if snip and repo
      repo.snip_path snip
    end
  end

  def read snip
    snip, repo = find_first_snip_and_repo snip
    if snip and repo
      repo.read snip
    end
  end

  def installed? snip
    path = self.install_repo.snip_path(snip)
    ( path.nil? ) ? false : File.file?( path )
  end
  def install snip
    original = snip
    raise "woah there, killer ... what're you trying to do?  you can't install to a remote repo." if self.install_repo.remote?
    unless installed? snip
      snip, repo = find_first_snip_and_repo snip
      if snip and repo
        require 'ftools'
        File.makedirs self.install_repo.location unless File.directory? self.install_repo.location
        raise "Problem accessing snip install directory #{self.install_repo.location}" unless File.directory? self.install_repo.location

        if snip.dependencies and not snip.dependencies.to_list.empty?
          snip.dependencies.to_list.each do |dependency|
            dependency = snip( dependency.strip.downcase )
            unless dependency.nil? or dependency == snip or installed? dependency
              puts "Installing dependency: #{dependency.filename}"
              self.install dependency
            end
          end
        end

        File.open( self.install_repo.snip_path(snip), 'w' ){ |f| f << repo.read(snip) }
        self.install_repo.reload
        return true

      else
        puts "Couldn't find snip to install: #{original.inspect}"
      end
    end
    false
  end

  def uninstall_all
    install_repo.all_snips.each { |snip| uninstall snip }
  end
  def uninstall snip
    if installed? snip and self.install_repo.local?
      snip_path = self.install_repo.snip_path(snip)
      File.delete snip_path if File.file? snip_path
      self.install_repo.reload
      return true unless File.file? snip_path
    end
    false
  end

end
