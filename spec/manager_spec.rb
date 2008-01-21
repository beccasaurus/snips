require File.dirname(__FILE__) + '/spec_helper'

describe Snip::Manager do

  it 'should have good defaults' do
    ENV.stub!(:[]).and_return(nil)
    manager = Snip::Manager.new
    manager.rc_file.should == '~/.sniprc'
    manager.install_path.should == '~/.snips'
    manager.search_path.should == [ '~/.snips' ].join(':')  # ADD default remote repo here, when setup
  end

  it 'should read SNIP_PATH environment variable, on load, if available, else use default' do
    ENV.should_receive(:[]).with('SNIP_RC').and_return( nil )
    ENV.should_receive(:[]).with('SNIP_PATH').and_return( '~/.snips:/another/path' )
    ENV.should_receive(:[]).with('SNIP_REPO').and_return( nil )
    manager = Snip::Manager.new
    manager.rc_file.should        == '~/.sniprc'
    manager.install_path.should   == '~/.snips'
    manager.search_path.should    == '~/.snips:/another/path'
  end

  it 'should read SNIP_REPO environment variable, on load, if available, else use default' do
    ENV.should_receive(:[]).with('SNIP_RC').and_return( nil )
    ENV.should_receive(:[]).with('SNIP_PATH').and_return( nil )
    ENV.should_receive(:[]).with('SNIP_REPO').and_return( '/here/is/repo' )
    manager = Snip::Manager.new
    manager.rc_file.should        == '~/.sniprc'
    manager.install_path.should   == '/here/is/repo'
    manager.search_path.should    == '~/.snips'
  end

  it 'should read SNIP_RC file, using environment variable, if given, else checking default' do
    ENV.should_receive(:[]).with('SNIP_RC').and_return( File.expand_path('examples/sniprc') )
    ENV.should_receive(:[]).with('SNIP_PATH').and_return( nil )
    ENV.should_receive(:[]).with('SNIP_REPO').and_return( nil )
    manager = Snip::Manager.new
    manager.rc_file.should        == File.expand_path('examples/sniprc')
    manager.install_path.should   == 'examples/install_here'
    manager.search_path.should    == [ '~/.snips', 'examples/snips' ].join(':')
  end

  it 'should return snip/snips with first matches found, going thru search path'

  it 'should create directory for install repository (when needed), if does not exist'
  it 'should be able to check if a snip is locally installed?'

  it 'should return #which snip is the first found and its full local or remote path'
  it 'should support remote repos in its search path'

  it 'should NOT install a snip from the same repo as the install repo (try to install to itself)'
  it 'should be able to install from a local repo'
  it 'should be able to install from a remote repo'
  it 'should be able to support HTTP AUTHENTICATION for pulling/installing from remote repos'
  it 'should be able to install a specific version of a snip (including old versions)'

  it 'should be able to uninstall/remove from a local repo'
  it 'should NOT be able to uninstall/remove from a remote repo (atleast for now)'

  it 'should be able to push to a local repo'
  it 'should be able to push to a remote repo'
  it 'should be able to support HTTP AUTHENTICATION for pushing to remote repos'

end
