require File.dirname(__FILE__) + '/spec_helper'
require 'rack'

describe Snip::Repo do

  before do
    Snip::Repo.class_eval { # Snip::Repo.stub! not working for some reason ... doing this to stub out
      def open(url)
        response_text = Rack::MockRequest.new( Snip::Server.new( 'examples/snips' ) ).get(url).body
        response_text.stub!(:read).and_return(response_text); response_text
      end }

    @repo = Snip::Repo.new(File.dirname(__FILE__) + '/../examples/snips')
    @remote_repo = Snip::Repo.new( 'http://localhost' )
    @local_and_remote_repos = [ @repo, @remote_repo ]
  end

  it 'should have a reload method to reload @all_snips' do
    @repo.all_snips.length.should == 8
    @repo.all_snips.clear
    @repo.instance_eval{ @all_snips }.should be_empty
    @repo.reload
    @repo.instance_eval{ @all_snips }.length.should == 8
    @repo.all_snips.length.should == 8
  end

  it 'should lazy load snips (load when .snips or .current/all_snips called)' do
    @local_and_remote_repos.each do |repo|
      repo.instance_eval { @all_snips }.should be_nil
      repo.all_snips
      repo.instance_eval { @all_snips }.should_not be_nil
    end
  end

  it 'should load all Snips from a directory' do
    Snip::Repo.new('/some/crazy/dir').snips.should be_empty

    @local_and_remote_repos.each do |repo|
      repo.all_snips.length.should == 8 # retuns old versions, too
      repo.snips.length.should == 7 # only returns CURRENT snips
      repo.all_snips.map(&:name).sort.should == %w( blah-ti-da_something erb haml haml_something sass sass sass_something test )
      repo.snips.map(&:name).sort.should == %w( blah-ti-da_something erb haml haml_something sass sass_something test )
    end
  end  

  it 'should return a single, first found snip on #snip' do
    @local_and_remote_repos.each do |repo|
      repo.snip(/sass/).should be_a_kind_of(Snip)
      repo.snip(/sass/).name.should == 'sass'
      repo.snip(:sass).name.should == 'sass'
      lambda { repo.snip(:sass, :erb) }.should raise_error
    end
  end

  it 'should return a many, first found snips on #snips' do
    @local_and_remote_repos.each do |repo|
      repo.snips(/_something/).length.should == 3
      repo.snips('sass', /sass/, :sass).length.should == 2
      repo.snips(:sass, /_something/, :erb).length.should == 5
    end
  end

  it 'should be able to read a file' do
    @local_and_remote_repos.each do |repo|
      repo.read( :no_exist ).should be_nil
      repo.read( :test ).should == File.read( 'examples/snips/test-0001.rb' )
      repo.read( /sass/ ).should == File.read( 'examples/snips/sass-0100.rb' )
      lambda { repo.read( :test, :erb ) }.should raise_error
    end
  end

  it 'should list current snips' do
    @local_and_remote_repos.each do |repo|
      list = repo.list
      %w( sass haml erb blah-ti-da_something sass_something ).each { |word| list.should include(word) }
      ['sass (v 0100)','(v 0005)','erb (v 0001)'].each { |word| list.should include(word) }
      list.should_not include('sass (v 0099)')
    end
  end

  it 'should search current snips' do
    @local_and_remote_repos.each do |repo|
      repo.search( 'filter', :include => [:tags] ).length.should == 3           # haml, test, sass_something (b/c now string based, so filter*S* is a match)
      repo.search( 'filter', :include => [] ).length.should == 0                # 
      repo.search( 'filter', :include => [:description] ).length.should == 3    # haml, sass, erb
      repo.search( 'filter' ).length.should == 5                                # test, sass, haml, erb - FILTERS now match ... 
      repo.search( 'filter', :include => [:name] ).length.should == 0           #
      repo.search( 'erb', :include => [:name] ).length.should == 1              # erb
      repo.search( 'erb', :include => [:name,:name,:name] ).length.should == 1  # erb
      repo.search( 'sass', :include => [:name] ).length.should == 2             # sass, sass_something
      repo.search( 5, :include => [:version] ).length.should == 2               # haml, sass_something
      repo.search( 'I MADE some CHANGES' ).length.should == 0                   #
      repo.search( :erb, :include => :dependencies ).length.should == 1         # sass 0100
      repo.search( :erb, :include => :dependencies, :all => true ).length.should == 2     # sass 0100, sass 0099
      repo.search( 'I MADE some CHANGES', :include => [:changelog] ).length.should == 1   # sass 0100
      repo.search( 'I MADE some CHANGES', :include => :changelog ).length.should == 1     # sass 0100
      repo.search( 'I MADE some CHANGES', :include => 'changelog' ).length.should == 1     # sass 0100
      repo.search( 'I MADE some CHANGES', :include => [:changelog,:noexist] ).length.should == 1   # sass 0100
      repo.search( 'I MADE some CHANGES', :include => [:changelog,:noexist,'blah','jdklf'] ).length.should == 1   # sass 0100
    end
  end

end
