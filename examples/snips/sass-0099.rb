# Description:    SASS filter
# Author:         Joe Somebody <joe.somebody@blah-ti-dah.com>
# Dependencies:   erb
# Changelog:      
#
# first line here
# 
# Big Update
# ==========
#
# i made some changes:
# --------------------
#
# these:
#
#  * this
#  * __that__

snip :erb # require once?

if lib_available? 'haml'

  helpers :capture # for 'filter' method

  filters do
    sass { |text,binding| 
      Sass::Engine.new( filter(:erb){ text } ).render  # right now, filter needs to be loaded thru the 'capture' helper ... change this before release
    }
  end

end
