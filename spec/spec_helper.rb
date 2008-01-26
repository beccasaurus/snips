require File.dirname(__FILE__) + '/../lib/snips'

# override 'set defaults' to not include default remote repo in search path
class Snip::Manager
  def set_defaults
    self.variables      ||= {}
    self.path_seperator   = '$' 
    self.rc_file          = ENV['SNIP_RC']    || '~/.sniprc'
    self.search_path      = ENV['SNIP_PATH']  || '~/.snips' 
    self.install_path     = ENV['SNIP_REPO']  || '~/.snips'

    self.search_repos = []
  end
end
