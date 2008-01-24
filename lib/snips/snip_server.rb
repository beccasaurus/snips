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
      @snips = SnipServer::Communicator.repo.snips
      @snips = @snips.sort { |a,b| a.name.downcase <=> b.name.downcase } if @snips and not @snips.empty?
      @snips = [] if @snips.nil?
      render :snip_list
    end
  end

  class SnipIndex < R '/snips.index', '/snips.index.Z'
    def get
      headers['Content-Type'] = 'text/plain'
      headers['Content-Encoding'] = 'x-compress'
      compress = env.PATH_INFO[/\.Z$/] ? true : false
      index    = SnipServer::Communicator.repo.all_snips.inject(''){|all,snip| all << (snip.filename + "\n") }
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
      yaml     = SnipServer::Communicator.repo.all_snips.to_yaml
      if compress
        require 'zlib'
        Zlib::Deflate.deflate yaml
      else
        yaml
      end
    end
  end

  class ShowSnip < R '/([\w_-]+)'
    def get name
      @repo = SnipServer::Communicator.repo
      @snip = @repo.snip name
      render :show_snip
    end
  end

  class ShowVersionOfSnip < R '/([\w_-]+)/v(\d+)'
    def get name, version
      @repo = SnipServer::Communicator.repo
      @snip = @repo.all_snips.find { |snip| snip.name == name and snip.version.to_i == version.to_i }
      render :show_version_of_snip
    end
  end

  class Style < R '/style.css'
    def get
      headers['Content-Type'] = 'text/css'
      %[
          body {
            background-color: #333;
          }
          div#container {
              background-color: #ccc;
              width: 650px;
              padding: 4px;
              margin-top: 20px;
              margin: auto;
          }
          div#content {
            background-color: #eee;
            padding: 10px;
            min-height: 450px;
          }
          td {
            font-size: 0.8em;
          }
          td.header {
            font-weight: bold;
            width: 200px;
          }
          
          /* CODERAY (if installed) */
          table.CodeRay { margin-top: 20px; font-size: 1.2em; }
          #{ CodeRay::Encoders[:html]::CSS.new.stylesheet if require? 'coderay' }
      ]
    end
  end

end
module SnipServer::Views

  def layout
    html do
      head do 
        title 'snip server'
        link :rel => 'stylesheet', :type => 'text/css', :href => R(Style)
      end
      body do
        div.container! { div.content! { self << yield } }
      end
    end
  end
    
  def show_version_of_snip
    _snip_header
    _snip_source
  end

  def show_snip
    _snip_header
    table do
      tr { %w(version changelog).each { |header| td.header header } }
      @repo.log(@snip).each do |snip|
        tr {
          td { a "v #{snip.version.to_i}", :href => R(ShowVersionOfSnip, snip.name, snip.version.to_i.to_s) }
          td snip.changelog_summary
        }
      end
    end
    _snip_source
  end

  def _snip_header
    p { 
      a 'snips', :href => '/'
      text ' / '
      a @snip.name, :href => R(ShowSnip, @snip.name)
    }
  end

  def _snip_source
    if @snip.filename[/\.rb$/] and require? 'coderay'
      text CodeRay.scan(@repo.read(@snip), :ruby).div(:line_numbers => :table, :css => :class)
    else
      pre { code { @repo.read(@snip) } }
    end
  end

  def snip_list
    h1 'snip server'
    table do
      tr { %w( name description tags version ).each { |header| td.header { header } } }
      @snips.each do |snip|
        tr do
          td { a snip.name, :href => R(ShowSnip, snip.name) }
          td snip.description
          td snip.tags.join(', ')
          td 'v ' + snip.version.to_i.to_s
        end
      end
    end
  end

end
