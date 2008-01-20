#
# An integrated web server for hosting / sharing snips
#
# Basically, a front-end for a _local_ repository, so it can be used _remotely_
#
# Also contains utility methods for creating / running your own snip server(s)
#
class Snip::Server
  attr_accessor :repo, :app, :adapter

  def initialize repo_location
    puts "initialzing with #{repo_location}"
    @repo = Snip::Repo.new repo_location

    require 'rack'
    require 'snips/snip_server'
    # SnipServer.repo = @repo
    
    @app     = SnipServer
    @adapter = Rack::Adapter::Camping.new SnipServer
    puts "initialized ..."
  end

  def call env
    puts "called call!"
    [200,{},'hi']
    @adapter.call env
  end

  # basically for testing - for now
  def run
    require 'thin'
    Rack::Handler::Thin.run self
  end

end
