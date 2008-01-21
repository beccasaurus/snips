$:.unshift File.dirname(__FILE__)

%w( symbol metaid hash array             ).each { |lib| require 'snips/hacks/'  + lib }
%w( indifferent_variable_hash            ).each { |lib| require 'snips/mixins/' + lib }
%w( snip repo manager server bin version ).each { |lib| require 'snips/'        + lib }
