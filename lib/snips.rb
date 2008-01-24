$:.unshift File.dirname(__FILE__)

require 'rubygems'

%w( object symbol metaid hash array      ).each { |lib| require 'snips/hacks/'  + lib }
%w( indifferent_variable_hash            ).each { |lib| require 'snips/mixins/' + lib }
%w( snip ).each { |lib| require 'snips/'        + lib }

# %w( snip repo manager server bin version ).each { |lib| require 'snips/'        + lib }
# require 'snips/mixins/global_snip_manager' ; include GlobalSnipHelpers
