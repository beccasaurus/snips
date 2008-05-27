= snips

snips makes it easy to share ruby (or any) files

snips was extracted from another project, resir, which uses snips to 
make it easy for users to use and share extensions / plugins

install the snips + load/require/read/eval them into your code, as needed

NOT PRODUCTION READY

== Installation

  $ gem install snips
  $ snip help 			# for usage

== Example Usage

  $ snip list			# display available local/remote snips
  $ snip install symbol-to_proc	# install a snip
  $ irb
  >> %w( rover spot ).map &:upcase
  TypeError: wrong argument type Symbol (expected Proc)
          from (irb):1
  >> require 'rubygems' ; require 'snips'
  => true
  >> require_snip 'symbol-to_proc'
  => true
  >> %w( rover spot ).map &:upcase
  => ["ROVER", "SPOT"]
