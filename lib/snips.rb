$:.unshift File.dirname(__FILE__)

%w( snip repo manager server bin ).each { |lib| require 'snips/' + lib }
