#
# Handles the command-line arguments to the 'snip' command
#
# Pretty undocumented ( copy/pasted from Resir )
#
class Snip::Bin
  require 'optparse'

  def self.snip_help
    <<doco

  snip

    Usage:
      snip ...
      snip [arguments...] [options...] # calls #{@default_command}

    Examples:
      snip ...

    Further help:
      snip help commands       list all 'snip' commands
      snip help <COMMAND>      show help on COMMAND
                                  (e.g. 'snip help help')
    Further information:
      http://snips.rubyforge.org
doco
  end
  
  class << self
    attr_accessor :default_command
  end

  def self.call command_line_arguments
    original = command_line_arguments.shift
    command  = original.gsub('-','') unless original.nil? # replace all dashes, to help catch -h / --help
    
    if command.nil?
      help
    elsif self.respond_to?command.to_sym
      self.send(command, *command_line_arguments)
    elsif @default_command
      self.send(@default_command, *( [original] + command_line_arguments ))
    else
      puts "not sure what to do.  please set_default :command"
    end
  end

  def self.set_default command
    @default_command = command.to_sym
  end

  # HELP
  def self.version_help
    <<doco
Usage: snip version

  Summary:
    Outputs the current version of snip
doco
  end
  def self.help_for command
    help_method = "#{command}_help".to_sym
    self.send( help_method ) if self.respond_to?help_method
  end

  # grab everything on a line ending with 'Summary:' and use it
  # as the command's summary (to display on `resir commands`)
  def self.summary_for command
    doco = help_for command
    if doco
      match = /Summary:\n*(.*)/.match doco
      if match and match.length > 1
        match[1].strip
      end
    end
  end

  # HELP
  def self.help_help
    <<doco
Usage: snip help COMMAND

  Summary:
    Provide help on the 'snip' command
doco
  end
  def self.help *command
    command = command.shift
    if command.nil?
      puts help_for( :snip )
    elsif (doco = help_for command)
      puts doco
    else
      puts "No documentation found for command: #{command}"
    end
  end

  # call a system command (returning the results) but puts the command before executing
  def self.system_command cmd
    puts cmd
    `#{cmd}`
  end

  # VERSION
  def self.version_help
    <<doco
Usage: resir version

  Summary:
    Display the current version of resir
doco
  end
  def self.version *no_args
    puts Snip::VERSION::STRING
  end

  # shortcuts to support calling -h / -v for help/version
  class << self
    alias h help
    alias v version
  end

  #
  #  ^ snips bin core
  #

  # require more commands (simple extensions to Resir::Bin)
  #
  %w( commands console snips debug ).each { |cmd| require File.dirname(__FILE__) + "/commands/#{cmd}" }

end
