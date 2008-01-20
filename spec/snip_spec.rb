require File.dirname(__FILE__) + '/spec_helper'
require 'time'

describe Snip, 'new' do

  def path_to_snip_file full_snippet_filename
    File.dirname(__FILE__) + '/../examples/snips/' + full_snippet_filename
  end

  it 'should parse snip files - erb.0001.rb test' do
    snip = Snip.new path_to_snip_file('erb.0001.rb')
    snip.description.should == 'ERB filter'
    snip.author.should == 'Joe Somebody <joe.somebody@blah-ti-dah.com>'
    snip.author_name.should == 'Joe Somebody'
    snip.author_email.should == 'joe.somebody@blah-ti-dah.com'
    snip.dependencies.should be_empty
    snip.name.should == 'erb'
    snip.version.should == '0001'
    snip.tags.should == %w( this that resir neat_ness and-that )
  end

  it 'should parse snip files - haml.0005.rb test' do
    snip = Snip.new path_to_snip_file('haml.0005.rb')
    snip.description.should == 'haml filter'
    snip.author_name.should == 'John Smith'
    snip.author_email.should == 'john@something.com'
    snip.dependencies.should be_empty
    snip.name.should == 'haml'
    snip.version.should == '0005'
    snip.tags.should be_empty
  end

  it 'should parse snip files - test.0001.rb test' do
    snip = Snip.new path_to_snip_file('test.0001.rb')
    snip.description.should == 'a test snip to use to test the snip server'
    snip.author_name.should == 'remi'
    snip.author_email.should == 'remi@remitaylor.com'
    snip.dependencies.should == %w( haml sass )
    snip.name.should == 'test'
    snip.version.should == '0001'
  end

end

describe Snip, 'parse' do

  it 'should return nil if passed something that evalates to an empty string' do
    Snip.parse('             ').should == nil
  end

  it 'should return a valid, but empty, Snip when passed a simple non-empty string' do
    snip = Snip.parse 'hello'
    snip.should be_a_kind_of(Snip)
    snip.author.should be_nil
    snip.description.should be_nil
    snip.author_name.should be_nil
    snip.author_email.should be_nil
    snip.dependencies.should be_empty
    snip.changelog.should be_nil
    snip.tags.should be_empty
  end

  it 'should parse a string as I expect it to!' do

    snip = Snip.parse <<text
# author: remi
# DePendencIes:           erb, haml blah
# some more stuff here
#
# shouldn't mess with dependencies cause 
#   dependencies isn't multi-line
#
#author: joe smith
#  kdjsfklsjfklsdjflksjlfkj dsjfsd jfsdk
# DaTE:             Jan 18 2008
# 
# Unknown: who knows ...
# tags:   hello-there, foo, bar    ;        ;     chunky/    \ bacon \   
#
#Randomness ....
#
# changeLOG:
#     first line
#
# I made these ass changes
#=======================
#
#  * this
#  * and this too
#
# desCriptioN :   should be nil cause space before the ':'


# author: NOT Joe Smith

def some_code
    'hi!'
end
text
    snip.should be_a_kind_of(Snip)
    snip.author.should == 'joe smith'
    snip.author_name.should == 'joe smith'
    snip.author_email.should be_nil
    snip.description.should be_nil
    snip.dependencies.should == %w( erb haml blah )
    snip.date.should == Time.parse('Jan 18 2008')
    snip.tags.should == %w( hello-there foo bar chunky bacon )
    snip.changelog.should == <<log.chomp

     first line

 I made these ass changes
=======================

  * this
  * and this too

 desCriptioN :   should be nil cause space before the ':'
log
    snip.changelog_summary.should == 'first line'
    snip.source.should == <<text



# author: NOT Joe Smith

def some_code
    'hi!'
end
text
  end

end
