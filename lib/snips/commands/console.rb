class Snip::Bin

  # CONSOLE
  def self.console_help
    <<doco
Usage: snip console

  About:
    ...

  Summary:
    Launch interactive console ...

doco
  end
  def self.console
    unless dirs.nil? or dirs.empty?
      #$server = Snip::Server.new *dirs
      #$sites  = $server.sites
      #puts "resir console started\n\n"
      #puts "variables:"
      #puts "  $server:   the loaded Snip::Server"
      #puts "  $sites:    the loaded Snip::Site's\n\n"
    else
      #puts "resir console started\n\n"
      #puts "use `resir console my-site` to start console with sites\n\n"
    end

    require 'irb'
    ARGV.clear
    IRB.start
  end

end
