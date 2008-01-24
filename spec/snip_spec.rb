require File.dirname(__FILE__) + '/spec_helper'

describe Snip do

  it 'should act like an indifferent hash' do
    file = 'blah-1.0.rb'
    File.should_not_receive(:exists?).with file
    File.should_receive(:read).with( file ).and_return( '' )
    snip = Snip.new file
    snip.chunky = :bacon
    snip.chunky.should              == :bacon
    snip.vars.chunky.should         == :bacon
    snip.variables['chunky'].should == :bacon
  end

  it "shouldn't bother checking whether or not the file exists" do
    file = 'blah-1.0.rb'
    File.should_not_receive(:exists?).with file
    File.should_receive(:read).with( file ).and_return( '' )
    snip = Snip.new file 
    snip.filename.should    == file
    snip.name.should        == 'blah'
    snip.version.should     == '1.0'
    snip.extension.should   == 'rb'
  end

  it "should crap out with the default File IO exception if file doesn't exist" do
    file = 'blah-1.0.rb'
    File.should_not_receive(:exists?).with file
    lambda { snip = Snip.new( file ) }.should raise_error( Errno::ENOENT )
  end

end

describe Snip, 'parsing' do

  it "should properly parse out 'email headers'" do
    file = 'blah-1.0.rb'
    File.should_not_receive(:exists?).with file
    File.should_receive(:read).with( file ).and_return( <<snip )
#name: i can't override name
# 
# description: my wonderful description
#     continues on next
# lines
#     because
#         they're
#             not
#                 empty
#
# testing:
#   hello
#
#   there
#
# blah  :   no can do!
#w00t:      neat
#o
def something_important *args
  # ...
end
snip

    snip = Snip.new file
    snip.name.should        == 'blah'
    snip.testing.should     == '  hello'
    snip.keys.should_not    include('blah')
    snip.keys.should        include('w00t')
    snip.w00t.should        == "neat
o"
    snip.description.should == <<desc.chomp
my wonderful description
    continues on next
lines
    because
        they're
            not
                empty
desc

  end

end
