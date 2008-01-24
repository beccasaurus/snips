require File.dirname(__FILE__) + '/spec_helper'
require 'time'

describe Snip, 'new' do

  def path_to_snip_file full_snippet_filename
    File.dirname(__FILE__) + '/../examples/snips/' + full_snippet_filename
  end

  it 'should parse snip files - erb-0001.rb test' do
    snip = Snip.new path_to_snip_file('erb-0001.rb')
    snip.description.should == 'ERB filter'
    snip.author.should == 'Joe Somebody <joe.somebody@blah-ti-dah.com>'
    snip.name.should == 'erb'
    snip.version.should == '0001'
    snip.tags.to_list.should == %w( this that resir neat_ness and-that )
  end

  it 'should parse snip files - haml-0005.rb test' do
    snip = Snip.new path_to_snip_file('haml-0005.rb')
    snip.description.should == 'haml filter'
    snip.dependencies.should be_nil
    snip.name.should == 'haml'
    snip.version.should == '0005'
    snip.tags.to_list.should == %w( haml filter filters )
  end

  it 'should parse snip files - test-0001.rb test' do
    snip = Snip.new path_to_snip_file('test-0001.rb')
    snip.description.should == 'a test snip to use to test the snip server'
    snip.dependencies.to_list.should == %w( haml sass )
    snip.name.should == 'test'
    snip.version.should == '0001'
  end

  it 'should parse a string as I expect it to!' do
    File.should_receive(:read).and_return( <<text )
# author: remi
# DePendencIes:           erb, haml blah
#
# some more stuff here
#
# shouldn't mess with dependencies cause 
#   dependencies isn't multi-line
#
#author: joe smith
#
#  kdjsfklsjfklsdjflksjlfkj dsjfsd jfsdk
# DaTE:             Jan 18 2008
# 
# Unknown: who knows ...
# tags:   hello-there, foo, bar    ;        ;     chunky/    \ bacon \   
#
#Randomness ....
# another custom header:    this is the custom tag's content
#
# changeLOG:
#     first line
# I made these ass changes
#=======================
#  * this
#  * and this too
#
# desCriptioN :   should be nil cause space before the ':'


# author: NOT Joe Smith

def some_code
    'hi!'
end
text
    snip = Snip.new 'some-file-0.1.rb'
    snip.should be_a_kind_of(Snip)
    snip.unknown.should == 'who knows ...'
    snip.author.should == 'joe smith'
    snip.description.should be_nil
    snip.dependencies.to_list.should == %w( erb haml blah )
    Time.parse(snip.date).should == Time.parse('Jan 18 2008')
    snip.tags.to_list.should == %w( hello-there foo bar chunky bacon )

    snip.changelog.should == <<log.chomp
    first line
I made these ass changes
=======================
 * this
 * and this too
log
    # snip.changelog_summary.should == 'first line' # _summary is no more!  add it to repo or someplace for the TOOLS to use ... Snip doesn't need to know or care
  end

end
