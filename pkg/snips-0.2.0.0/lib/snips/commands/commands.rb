class Snip::Bin

  # COMMANDS
  def self.commands_help
    <<doco
Usage: snip commands

  Summary:
    List all 'snip' commands
doco
  end
  def self.commands *no_args
    commands = self.methods.grep( /_help/ ).collect{ |help_method| help_method.gsub( /(.*)_help/ , '\1' ) } - ['snip']
    commands.sort!
    before_spaces = 4
    after_spaces  = 18
    text = commands.inject(''){ |all,cmd| all << "\n#{' ' * before_spaces}#{cmd}#{' ' * (after_spaces - cmd.length)}#{summary_for(cmd)}" }
    puts <<doco
snip commands are:

    DEFAULT COMMAND   #{@default_command}
#{text}

For help on a particular command, use 'snip help COMMAND'.

If you've made a command and it's not showing up here, you
need to make help method named 'COMMAND_help' that returns 
your commands help documentation.
doco
#
#[NOT YET IMPLEMENTED:]
#Commands may be abbreviated, so long as they are unumbiguous.
#e.g. 'snip h commands' is short for 'snip help commands'.
#doco
  end

end
