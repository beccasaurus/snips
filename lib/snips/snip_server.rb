require 'camping'

Camping.goes :SnipServer


module SnipServer
  class Communicator
    meta_include IndifferentVariableHash
    eval "self.variables ||= {}"
  end
end
module SnipServer::Models; end
module SnipServer::Controllers
  
  class Index < R '/'
    def get
      @snips = SnipServer::Communicator.repo.snips.sort { |a,b| a.name.downcase <=> b.name.downcase }
      render :snip_list
    end
  end

  class SnipIndex < R '/snips.index', '/snips.index.Z'
    def get
      headers['Content-Type'] = 'text/plain'
      headers['Content-Encoding'] = 'x-compress'
      compress = env.PATH_INFO[/\.Z$/] ? true : false
      index    = SnipServer::Communicator.repo.snips.inject(''){|all,snip| all << (snip.filename + "\n") }
      if compress
        require 'zlib'
        Zlib::Deflate.deflate index
      else
        index
      end
    end
  end

  class SnipYaml < R '/snips.yaml', '/snips.yaml.Z'
    def get
      headers['Content-Type'] = 'text/plain'
      headers['Content-Encoding'] = 'x-compress'
      compress = env.PATH_INFO[/\.Z$/] ? true : false
      require 'yaml'
      yaml     = SnipServer::Communicator.repo.snips.to_yaml
      if compress
        require 'zlib'
        Zlib::Deflate.deflate yaml
      else
        yaml
      end
    end
  end

  class SnipFile < R '/' + Snip.file_regex.source
    def get name, version
      "... not sure how you got here ... the Snip::Server should have returned a file ..."
    end
  end

end
module SnipServer::Views

  def snip_list
    h1 'snip server'
    table do
      tr { %w( name description tags version ).each { |header| td { strong header } } }
      @snips.each do |snip|
        tr do
          td snip.name
          td snip.description
          td snip.tags.join(', ')
          td 'v ' + snip.version.to_i.to_s
        end
      end
    end
  end

end
