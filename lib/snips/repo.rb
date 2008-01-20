#
# Represents a repository of snips (local or remote)
#
class Snip::Repo
  attr_accessor :location, :all_snips

  # repo_location: local directory or url or remote repository
  def initialize repo_location
    @location = repo_location

    if remote?
      raise "Remote repos are currently unsupported!!!!" 

    else
      @location = File.expand_path @location

      if File.directory?@location
        snips = Dir[ File.join(@location, '*.rb') ].select { |file| file[Snip.file_regex] }
        @all_snips = snips.collect { |snip| Snip.new snip }.select { |snip| snip.header_vars.length > 0  }
      else
        @all_snips = []
      end
      
    end
  end

  # returns all snips, without old versions of any (using version number)
  def current_snips
    current = {}
    @all_snips.each do |snip|
      unless current.keys.include?snip.name and current[snip.name].version.to_i > snip.version.to_i
        current[snip.name] = snip
      end
    end
    current.values
  end

  # returns one snip (unless iterator method overriden)
  #
  #     snip :sass    # returns snip named 'sass'
  #     snip 'sass'   # returns snip names 'sass'
  #     snip /sass/   # returns first snip that matches /regex/
  #
  def snip name_or_matcher, iterator='find', snips_to_search=current_snips
    name_or_matcher = name_or_matcher.to_s if name_or_matcher.is_a?Symbol
    if name_or_matcher.is_a?Regexp
      snips_to_search.send( iterator ){ |snip| snip.name[name_or_matcher] }
    else
      snips_to_search.send( iterator ){ |snip| snip.name == name_or_matcher }
    end
  end
  
  # returns an Array of snips - one per argument (unless /regex/, then it returns all matches)
  #
  #     snips :sass, :erb    # returns the snips named 'sass' and 'erb'
  #     snips 'sass', :erb   # returns the snips named 'sass' and 'erb'
  #     snips /sass/, :erb   # returns ALL snips that match /sass/ as well as the 'erb' snip
  #
  def snips *names_or_matchers
    return current_snips if names_or_matchers.empty?

    names_or_matchers.inject([]) { |all,this| 
      if this.is_a?Regexp
        all += snip( this, 'select' )
      else
        all << snip( this )
      end
      all
    }.uniq
  end

  def self.is_remote? location
    not location.downcase[/^http/].nil?
  end
  def self.is_local? location;  not is_remote?         location;      end
  def remote?;                  Snip::Repo.is_remote?  @location;     end
  def local?;                   Snip::Repo.is_local?   @location;     end

end
