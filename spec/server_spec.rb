require File.dirname(__FILE__) + '/spec_helper'
require 'rack'

describe Snip::Server do

  before do
    @server  = Snip::Server.new 'examples/snips'
    @request = Rack::MockRequest.new @server
  end

  it 'should have access to a Snip::Repo' do
    @server.repo.all_snips.length.should == 8
    @server.repo.snips.length.should == 7
  end

  it 'should show current specs on index page'
  it 'should return the plain/text file for a snip at /#{snip filename}'

  it 'should show information about a snip, including full current changelog and the code (syntax highlighted) at /#{snipname}'
  it 'should show the history of a snip with one-liner change messages at /#{snipname}/history'
  it 'should show the history of a snip with one-liner change messages at /#{snipname}/log'

  it 'should return an RSS feed of the most recent snip history and changelog summaries at /rss'
  it 'should return an RSS feed of the more recent snip history etc for tags at /#{tagname}/rss'
  it 'should return an RSS feed of the more recent snip history etc for tags at /tag/#{tagname}/rss'
  it 'should return an RSS feed of the more recent snip history etc for tags at /tags/#{tagname}/rss'
  it 'should return an RSS feed of the most recent snip hitory for a specific snip at /#{snipname}/rss'

  it 'should show tagged snips at /#{tagname}'
  it 'should show tagged snips at /#{tag1}+#{tag2}'

  it 'should show tagged snips at /tag/#{tagname}'
  it 'should show tagged snips at /tags/#{tagname}'

  it 'should return a plain text index of snip names at /snips.index'
  it 'should return a compressed index of snip names at /snips.index.Z'

  it 'should return plain text yaml data for snips at /snips.yaml'
  it 'should return compressed yaml data for snips at /snips.yaml.Z'

  it 'should return a snip index for /#{tagname}/snips.index'
  it 'should return a snip index for /#{tag1}+#{tag2}/snips.index'

  it 'should return a yaml data for /#{tagname}/snips.yaml'
  it 'should return a yaml data for /#{tag1}+#{tag2}/snips.yaml'

end
