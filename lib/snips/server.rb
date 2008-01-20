#
# An integrated web server for hosting / sharing snips
#
# Basically, a front-end for a _local_ repository, so it can be used _remotely_
#
# Also contains utility methods for creating / running your own snip server(s)
#
class Snip::Server
  attr_accessor :repo

  def initialize repo_location
    @repo = Snip::Repo.new repo_location
  end

end
