# Description:    SASS filter
# Author:         Joe Somebody <joe.somebody@blah-ti-dah.com>
# Dependencies:   erb
# Changelog:      disabled layout and set css header, by default
# 
# i made some changes:
#
#  * i did this ... and did this ... and __this__ *might* `even` show __in__ *markdown*
#  * also this

snip :erb # require once?

if lib_available? 'haml'

  helpers :capture # for 'filter' method

  filters do
    sass { |text,binding| 
      eval( '@layout = nil', binding ) # disable layout
      eval( %{response.header['Content-Type'] = 'text/css' if defined?response}, binding ) # set to text/css
      Sass::Engine.new( filter(:erb){ text } ).render  # right now, filter needs to be loaded thru the 'capture' helper ... change this before release
    }
  end

end
