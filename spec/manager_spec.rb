require File.dirname(__FILE__) + '/spec_helper'

describe Snip::Manager do

  # to call before making a new Snip::Manager, to load up the sniprc
  def use_example_sniprc
    ENV.should_receive(:[]).with('SNIP_RC').and_return( File.expand_path('examples/sniprc') )
    ENV.should_receive(:[]).with('SNIP_PATH').and_return( nil )
    ENV.should_receive(:[]).with('SNIP_REPO').and_return( nil )
  end

  def setup_default_manager
    use_example_sniprc
    @manager = Snip::Manager.new
  end

  # using http://localhost/ as search path
  def setup_manager_with_remote_search_path
    ENV.should_receive(:[]).with('SNIP_RC').and_return( File.expand_path('examples/sniprc_with_remote') )
    ENV.should_receive(:[]).with('SNIP_PATH').and_return( nil )
    ENV.should_receive(:[]).with('SNIP_REPO').and_return( nil )
    @manager = Snip::Manager.new
  end

  it 'should have good defaults' do
    ENV.stub!(:[]).and_return(nil)
    File.stub!(:read).and_return('')
    
    manager = Snip::Manager.new
    manager.rc_file.should == '~/.sniprc'
    manager.install_path.should == '~/.snips'
    manager.path_seperator.should == '$'
    manager.search_path.should == [ '~/.snips' ].join('$')  # ADD default remote repo here, when setup
  end

  it 'should read SNIP_PATH environment variable, on load, if available, else use default' do
    File.stub!(:read).and_return('')
    ENV.should_receive(:[]).with('SNIP_RC').and_return( nil )
    ENV.should_receive(:[]).with('SNIP_PATH').and_return( '~/.snips$/another/path' )
    ENV.should_receive(:[]).with('SNIP_REPO').and_return( nil )
    
    manager = Snip::Manager.new
    manager.rc_file.should        == '~/.sniprc'
    manager.install_path.should   == '~/.snips'
    manager.search_path.should    == '~/.snips$/another/path'
  end

  it 'should read SNIP_REPO environment variable, on load, if available, else use default' do
    File.stub!(:read).and_return('')
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
    manager.search_path.should    == [ '~/.snips', 'examples/snips' ].join('$')
  end

  it 'should support http:// paths with :PORT in search paths, and not mess up cause of the ":" character (switched to $ char)' do
    File.stub!(:read).and_return('')
    ENV.should_receive(:[]).with('SNIP_RC').and_return( nil )
    ENV.should_receive(:[]).with('SNIP_PATH').and_return( '$~/.snips$/another/path$http://somesite.com:80$/a/path$https://snips.remi.org:4407/snips/here$/root/.snips$' )
    ENV.should_receive(:[]).with('SNIP_REPO').and_return( nil )

    # open-uri checks these puppies - which we've gotta handle cause we're passing http:// remote repo paths
    ENV.should_receive(:[]).with('http_proxy').and_return( nil )
    ENV.should_receive(:[]).with('HTTP_PROXY').and_return( nil )
    ENV.should_receive(:[]).with('https_proxy').any_number_of_times.and_return( nil )
    ENV.should_receive(:[]).with('HTTPS_PROXY').any_number_of_times.and_return( nil )

    manager = Snip::Manager.new
    manager.rc_file.should        == '~/.sniprc'
    manager.install_path.should   == '~/.snips'
    manager.search_paths.should   == [ '~/.snips', '/another/path', 'http://somesite.com:80', '/a/path', 'https://snips.remi.org:4407/snips/here', '/root/.snips' ]
  end

  it 'should load up repos for search paths and for install path' do
    use_example_sniprc
    manager = Snip::Manager.new
    manager.search_path.should    == [ '~/.snips', 'examples/snips' ].join('$')
    manager.search_paths.should   == [ 'examples/install_here', '~/.snips', 'examples/snips' ]
    manager.search_repos.length.should == 3       # make sure this is the same object_id as install_repo?
    manager.install_repo.snips.length.should == 0 # because none installed
    manager.install_repo.object_id.should == manager.search_repos.first.object_id
  end

  it 'should return snip/snips with first matches found, going thru search path' do
    setup_default_manager
    File.stub!(:read).and_return('')
    @manager.snip( :sass ).filename.should == 'sass-0100.rb'
    @manager.search_repos.delete @manager.search_repos.find { |repo| repo.location == File.expand_path('~/.snips') }
    @manager.snips.length.should == 7
    @manager.all_snips.length.should == 8
  end

=begin
  it 'should check installed snips first when searching or calling #which'

  it 'should create directory for install repository (when needed), if does not exist'
  it 'should be able to check if a snip is locally installed?'

  it 'should return #which snip is the first found and its full local or remote path'
  it 'should support remote repos in its search path'

  it 'should NOT install a snip from the same repo as the install repo (try to install to itself)'
=end

  it 'should be able to install from a local repo' do
    setup_default_manager
    
    @manager.installed?(:sass).should == false
    @manager.install(:sass).should == true
    @manager.installed?(:sass).should == true
    @manager.install(:sass).should == false
    @manager.install(:unknown).should == false
    @manager.installed?(:sass).should == true
    @manager.uninstall(:sass).should == true
    @manager.uninstall(:sass).should == false
    @manager.installed?(:sass).should == false

    @manager.uninstall_all
  end

  it 'dependencies should work' do
    setup_default_manager
    
    snip_name = 'blah-ti-da_something'
    @manager.installed?(snip_name).should == false
    @manager.installed?(:sass).should     == false

    @manager.install(snip_name).should    == true
    @manager.install(snip_name).should    == false

    @manager.installed?(snip_name).should == true
    @manager.installed?(:sass).should     == true

    @manager.uninstall(:sass).should      == true
    @manager.installed?(:sass).should     == false
    @manager.installed?(snip_name).should == true
    @manager.uninstall(snip_name).should  == true
    @manager.installed?(snip_name).should == false

    @manager.uninstall_all
  end

=begin
  it 'should be able to install from a remote repo'
  it 'should be able to support HTTP AUTHENTICATION for pulling/installing from remote repos'
  it 'should be able to install a specific version of a snip (including old versions)'

  it 'should be able to uninstall/remove from a local repo'
  it 'should NOT be able to uninstall/remove from a remote repo (atleast for now)'

  it 'should be able to push to a local repo'
  it 'should be able to push to a remote repo'
  it 'should be able to support HTTP AUTHENTICATION for pushing to remote repos'
=end

end
