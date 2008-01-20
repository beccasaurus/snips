# Description:    haml filter
# Author:         John Smith <john@something.com>
# tags: haml filter filters haml haml filter

if lib_available?'haml'
  filters do
    haml { |text,binding| Haml::Engine.new(text).render(binding) }
  end
end
