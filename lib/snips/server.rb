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
    @repo = Snip::Repo.new repo_location
    raise "what in the world do you think you're doing?  i only serve local repos" unless @repo.local?

    require 'rack'
    require 'snips/snip_server'
    SnipServer::Communicator.repo = @repo
    
    @app     = SnipServer
    @adapter = Rack::Adapter::Camping.new SnipServer
  end

  def call env
    request = Rack::Request.new(env)
    if request.env.PATH_INFO.sub(/^\//,'')[Snip::file_regex]
      return Rack::File.new( @repo.location  ).call( env )
    else
      @adapter.call env
    end
  end

  # basically for testing - for now
  def run
    require 'thin'
    Rack::Handler::Thin.run self
  end

end
