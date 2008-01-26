#
# An integrated web server for hosting / sharing snips
#
# Basically, a front-end for a _local_ repository, so it can be used _remotely_
#
# Also contains utility methods for creating / running your own snip server(s)
#
class Snip::Server
  attr_accessor :repo

  def initialize repo_location
    @repo = Snip::Repo.new repo_location
    raise "what in the world do you think you're doing?  i only serve local repos" unless @repo.local?
    require 'rack'
  end

  def call env
    request  = Rack::Request.new env
    path     = request.env.PATH_INFO.sub(/^\//,'')
    compress = path[/\.Z$/]
    response = Rack::Response.new
    response.headers['Content-Type'] = 'text/plain'
    response.headers['Content-Encoding'] = 'x-compress' if compress
    require 'zlib' if compress

    if    path == 'snips.index' or path == 'snips.index.Z'
      index         = self.repo.all_snips.inject(''){ |all,snip| all << (snip.filename + "\n") }
      response.body = (compress) ? Zlib::Deflate.deflate(index) : index

    elsif path == 'snips.yaml'  or path == 'snips.yaml.Z'
      require 'yaml'
      yaml          = self.repo.all_snips.to_yaml
      response.body = (compress) ? Zlib::Deflate.deflate(yaml) : yaml

    elsif path[/^snips\//] and path.gsub(/^snips\//, '')[Snip::FILE_REGEX]
      env.PATH_INFO.gsub!( /^\/snips\//, '' )
      return Rack::File.new( @repo.location  ).call( env )
    
    else
      return fallback( env )

    end

    response.finish
  end

  def fallback env
    [ 404, {'Content-Type' => 'text/plain'}, <<body ]
Sorry, this snip server doesn't know how to handle your request.

If this is your snip server, you can easily override this method to handle your request by 
overriding Snip::Server#fallback, which accepts an argument for environment/request variables.
body
  end

  def run options
    require 'thin'
    Rack::Handler::Thin.run self, options
  end

end
