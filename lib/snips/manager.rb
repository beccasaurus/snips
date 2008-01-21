#
# Manages installing/removing/reading/etc snips from various snip::repos
#
class Snip::Manager
  include IndifferentVariableHash

  def initialize install_path=nil, *search_paths
    set_defaults
    load_config

  end

  def set_defaults
    self.variables  ||= {}
    self.rc_file      = ENV['SNIP_RC']    || '~/.sniprc'
    self.search_path  = ENV['SNIP_PATH']  || '~/.snips'
    self.install_path = ENV['SNIP_REPO']  || '~/.snips'
  end

  def load_config
    rc = File.expand_path self.rc_file
    puts "RC => #{rc} exists? #{File.file?rc}"
    eval File.read(rc) if File.file?rc
  end

end
