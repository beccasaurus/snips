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
