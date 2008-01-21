#
# Represents a repository of snips (local or remote)
#
# as a general rule, methods that accept an argument named 'snip'
# _should_ accept :snip_name, 'snip name', /snip Regexp/, or Snip objects
#
# all methods ensure the argument is a snip by:
#     snip = snip( snip ) unless snip.is_a?Snip
#
class Snip::Repo
  attr_accessor :location, :all_snips

  # repo_location: local directory or url or remote repository
  def initialize repo_location
    @location = repo_location
    reload
  end

  def reload
    if remote?
      @location    = @location.gsub /\/$/, '' # remove trailing slash, if there
      
      begin
        require 'open-uri'
        yaml = open("#{@location}/snips.yaml.Z").read
        compressed = true
      rescue OpenURI::HTTPError    # try falling back to plain/text url
      rescue Errno::ECONNREFUSED
        begin
          yaml = open("#{@location}/snips.yaml").read
          compressed = false
        rescue OpenURI::HTTPError  # invalid
        rescue Errno::ECONNREFUSED
          yaml = nil
          compressed = false
        end
      end

      if compressed
        require 'zlib'
        yaml = Zlib::Inflate.inflate yaml
      end

      if yaml
        require 'yaml'
        @all_snips = YAML::load yaml
      else
        @all_snips = []
      end

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

  def snip_path snip
    snip = self.snip( snip ) unless snip.is_a?Snip
    return nil unless snip.is_a?Snip
    File.join location, snip.filename
  end

  def read snip
    snip = snip( snip ) unless snip.is_a?Snip
    local? ? File.read( snip_path(snip) ) : open( snip_path(snip) ).read if snip
  end

  def list
    current_snips.inject(''){ |all,snip| all << ("#{snip.name} (v #{snip.version.to_i})\n") }
  end

  def log snip
    snip = snip( snip ) unless snip.is_a?Snip
    all_snips.select { |x| x.name == snip.name }.sort { |a,b| b.version.to_i <=> a.version.to_i }
  end

  # currently does NOT support wildcard or regex search queries
  def search query, options = { :include => [:tags, :name, :description] }
    query = query.to_s.downcase
    snips = options[:all] ? all_snips : current_snips
    found = []
    options[:include] = [ options[:include] ] unless options[:include].is_a?Array
    options[:include].uniq.each do |snip_attribute|
      found += snips.select { |snip| 
        value = snip.send(snip_attribute)
        value.downcase.include?query if value 
      }
    end
    found.uniq
  end

  def self.is_remote? location
    not location.downcase[/^http/].nil?
  end
  def self.is_local? location;  not is_remote?         location;      end
  def remote?;                  Snip::Repo.is_remote?  @location;     end
  def local?;                   Snip::Repo.is_local?   @location;     end

end