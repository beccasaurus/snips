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
    self.search_path      = ENV['SNIP_PATH']  || '~/.snips'
    self.install_path     = ENV['SNIP_REPO']  || '~/.snips'

    self.search_repos = []
  end

  def load_config
    rc = File.expand_path self.rc_file
    eval File.read(rc) if File.file?rc
  end

  def search_paths
    paths = self.search_path.split(self.path_seperator).select { |path| not path.empty? }.uniq
    paths = [self.install_path] + paths unless paths.include? self.install_path
    paths || []
  end

  def all_repos
    ( self.search_repos << self.install_repo ).uniq
  end

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
  def find_first_snip_and_repo name_or_matcher
    found_snip, found_repo = nil, nil
    all_repos.find{ |repo| 
      found_snip = repo.snip(name_or_matcher) 
      found_repo = repo if found_snip
      found_snip
    }
    return found_snip, found_repo
  end

  def installed? snip
    puts "installed? #{snip.inspect}"
    path = self.install_repo.snip_path(snip)
    puts "install path = #{path.inspect}"
    puts "exists?  #{ File.file?path }" unless path.nil?
    ( path.nil? ) ? false : File.file?( path )
  end
  def install snip
    raise "wow there, killer ... what're you trying to do?  you can't install to a remote repo." if self.install_repo.remote?
    unless installed? snip
      snip, repo = find_first_snip_and_repo snip
      if snip and repo
        require 'ftools'
        File.makedirs self.install_repo.location unless File.directory? self.install_repo.location
        raise "Problem accessing snip install directory #{self.install_repo.location}" unless File.directory? self.install_repo.location

        File.open( self.install_repo.snip_path(snip), 'w' ){ |f| f << repo.read(snip) }
        self.install_repo.reload
        return true

      end
    end
    false
  end
  def uninstall snip
    if installed? snip
      snip_path = self.install_repo.snip_path(snip)
      File.delete snip_path if File.file? snip_path
      self.install_repo.reload
      return true unless File.file? snip_path
    end
    false
  end

end
