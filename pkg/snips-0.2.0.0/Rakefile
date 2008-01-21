require 'config/requirements'
require 'config/hoe' # setup Hoe + all gem configuration

Dir['tasks/**/*.rake'].each { |rake| load rake }

require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
      # files = ['README', 'LICENSE', 'CHANGELOG', 'lib/**/*.rb', 'doc/**/*.rdoc', 'test/*.rb']
      files = ['README','lib/**/*.rb', 'doc/**/*.rdoc', 'test/*.rb']
      rdoc.rdoc_files.add(files)
      rdoc.main = 'README'
      rdoc.title = 'My RDoc'
      template = '/usr/local/lib/ruby/gems/1.8/gems/allison-2.0.2/lib/allison.rb'
      rdoc.template = template if File.exist?template
      rdoc.template = '/usr/lib/ruby/gems/1.8/gems/allison-2.0.2/lib/allison.rb' unless File.exist?template
      rdoc.rdoc_dir = 'doc'
      rdoc.options << '--line-numbers' << '--inline-source'
end
