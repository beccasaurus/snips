require File.dirname(__FILE__) + '/spec_helper'

describe Snip::Repo do

  before do
    @repo = Snip::Repo.new(File.dirname(__FILE__) + '/../examples/snips')
  end

  it 'should load all Snips from a directory' do
    Snip::Repo.new('/some/crazy/dir').snips.should be_empty

    @repo.all_snips.length.should == 8 # retuns old versions, too
    @repo.snips.length.should == 7 # only returns CURRENT snips
    @repo.all_snips.map(&:name).sort.should == %w( blah-ti-da_something erb haml haml_something sass sass sass_something test )
    @repo.snips.map(&:name).sort.should == %w( blah-ti-da_something erb haml haml_something sass sass_something test )
  end  

  it 'should return a single, first found snip on #snip' do
    @repo.snip(/sass/).should be_a_kind_of(Snip)
    @repo.snip(/sass/).name.should == 'sass'
    @repo.snip(:sass).name.should == 'sass'
    lambda { @repo.snip(:sass, :erb) }.should raise_error
  end

  it 'should return a many, first found snips on #snips' do
    @repo.snips(/_something/).length.should == 3
    @repo.snips('sass', /sass/, :sass).length.should == 2
    @repo.snips(:sass, /_something/, :erb).length.should == 5
  end

end
