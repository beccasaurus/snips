require File.dirname(__FILE__) + '/spec_helper'
require 'rack'
require 'zlib'
require 'yaml'

describe Snip::Server do

  before do
    @server  = Snip::Server.new 'examples/snips'
    @request = Rack::MockRequest.new @server
  end

  it 'should have access to a Snip::Repo' do
    @server.repo.all_snips.length.should == 8
    @server.repo.snips.length.should == 7
  end

  it 'should return the plain/text file for a snip at /#{snip filename}' do
    response = @request.get '/snips/test-0001.rb'
    response.body.should == File.read( 'examples/snips/test-0001.rb' )
  end

  it 'should return a plain text index of snip names at /snips.index' do
    response = @request.get '/snips.index'
    @server.repo.snips.each do |snip|
      response.body.should include( snip.filename )
    end
  end

  it 'should return a compressed index of snip names at /snips.index.Z' do
    response = @request.get '/snips.index.Z'
    Zlib::Inflate.inflate( response.body ).should == @request.get( '/snips.index' ).body
  end

  it 'should return plain text yaml data for snips at /snips.yaml' do
    response = @request.get '/snips.yaml'
    data = YAML::load response.body
    data.length.should == @server.repo.all_snips.length
  end
  
  it 'should return compressed yaml data for snips at /snips.yaml.Z' do
    response = @request.get '/snips.yaml.Z'
    Zlib::Inflate.inflate( response.body ).should == @request.get( '/snips.yaml' ).body
  end

end
