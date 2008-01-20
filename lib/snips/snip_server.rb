require 'camping'

Camping.goes :SnipServer

module SnipServer; end
module SnipServer::Models; end
module SnipServer::Controllers
  
  class Index < R '/'
    def get
      'hello world'
    end
  end

end
module SnipServer::Views; end
