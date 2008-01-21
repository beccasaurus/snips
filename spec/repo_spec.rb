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
  end

  it 'should load all Snips from a directory' do
    Snip::Repo.new('/some/crazy/dir').snips.should be_empty

    @repo.all_snips.length.should == 8 # retuns old versions, too
    @repo.snips.length.should == 7 # only returns CURRENT snips
    @repo.all_snips.map(&:name).sort.should == %w( blah-ti-da_something erb haml haml_something sass sass sass_something test )
    @repo.snips.map(&:name).sort.should == %w( blah-ti-da_something erb haml haml_something sass sass_something test )
  end  
  it 'should load all Snips from a directory (remote)' do
    @remote_repo.all_snips.length.should == 8 # retuns old versions, too
    @remote_repo.snips.length.should == 7 # only returns CURRENT snips
    @remote_repo.all_snips.map(&:name).sort.should == %w( blah-ti-da_something erb haml haml_something sass sass sass_something test )
    @remote_repo.snips.map(&:name).sort.should == %w( blah-ti-da_something erb haml haml_something sass sass_something test )
  end

  it 'should return a single, first found snip on #snip' do
    @repo.snip(/sass/).should be_a_kind_of(Snip)
    @repo.snip(/sass/).name.should == 'sass'
    @repo.snip(:sass).name.should == 'sass'
    lambda { @repo.snip(:sass, :erb) }.should raise_error
  end
  it 'should return a single, first found snip on #snip (remote)'

  it 'should return a many, first found snips on #snips' do
    @repo.snips(/_something/).length.should == 3
    @repo.snips('sass', /sass/, :sass).length.should == 2
    @repo.snips(:sass, /_something/, :erb).length.should == 5
  end
  it 'should return a many, first found snips on #snips (remote)'

  it 'should be able to read a file' do

  end
  it 'should be able to read a file (remote)'

  it 'should list current snips'
  it 'should list current snips (remote)'

  it 'should search current snips'
  it 'should search current snips (remote)'

end
