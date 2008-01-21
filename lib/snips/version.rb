class Snip

  module VERSION
    MAJOR = 0
    MINOR = 2
    TINY  = 0
    
    SCM = 25
    
    # ^ SCM set via script : `git log --pretty=oneline | wc -l`.strip

    STRING = [MAJOR, MINOR, TINY, SCM].join('.')
  end

end
