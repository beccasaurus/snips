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

end
