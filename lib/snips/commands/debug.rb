class Snip::Bin

  def self.debug_help
    <<doco
Usage: snip debug

  Summary:
    print out some debugging info for myself
doco
  end
  def self.debug *no_args
    puts "repos:"
    $SNIP_MANAGER.all_repos.each { |repo| puts "\t#{repo.location} (#{repo.snips.length} snips)" }
  end

end
