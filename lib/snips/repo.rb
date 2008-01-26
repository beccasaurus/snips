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
    @location = repo_location.strip
  end

  def all_snips
    reload if @all_snips.nil? or @all_snips.empty?
    @all_snips
  end

  def reload
    if remote?
      @location = @location.gsub /\/$/, '' # remove trailing slash, if there
      reload_remote
    else
      @location = File.expand_path @location
      reload_local
    end
  end

  def reload_local
    @all_snips ||= []
    @all_snips = (File.directory?@location) ? Dir[ File.join(@location, '*') ].collect { |file| Snip.new file }.select { |snip| snip.headers.length > 0  } : []
  end

  def reload_remote
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
      begin
        yaml = Zlib::Inflate.inflate yaml
      rescue Zlib::DataError
        yaml = nil
      end
    end

    if yaml
      require 'yaml'
      @all_snips = YAML::load yaml
    else
      @all_snips = []
    end
  end

  # returns all snips, without old versions of any (using version number)
  def current_snips
    current = {}
    self.all_snips.each do |snip|
      unless current.keys.include?snip.name and current[snip.name].version > snip.version
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
  def snip name_or_matcher, iterator='find', snips_to_search=self.current_snips
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

  # returns the full path to a snip
  #
  #     Snip::Repo.new( '/dir/snips' ).snip_path( :dog )        # => /dir/snips/dog-1.rb
  #     Snip::Repo.new( 'http://site.com' ).snip_path( :dog )   # => http://site.com/dog-1.rb
  #
  def snip_path snip
    snip = self.snip( snip ) unless snip.is_a?Snip
    return nil unless snip.is_a?Snip
    (local?) ? File.join(location, snip.filename) : File.join(location, 'snips', snip.filename)
  end

  # returns the full source of a snip
  #
  def read snip
    snip = snip( snip ) unless snip.is_a?Snip
    local? ? File.read( snip_path(snip) ) : open( snip_path(snip) ).read if snip
  end

  # returns a formatted list of all snips in repo
  #
  # for a custom format, pass a block that accepts a Snip object as an argument
  # and returns a string
  #
  #     @repo.list { |snip| "the snip's name is #{snip.name} and it is version #{snip.version}" }
  #
  def list &format
    current_snips.inject('') do |all,snip|
      unless format.nil?
        all << "#{ format.call( snip ) }\n"
      else
        all << ("#{snip.name} (v #{snip.version})\n")
      end
    end
  end

  # returns all of the versions of a snip, starting with the most recent
  #
  #     @repo.log( :dog )  # => [ <Dog Snip v3><Dog Snip v2><Dog Snip v1> ]
  def log snip
    snip = snip( snip ) unless snip.is_a?Snip
    all_snips.select { |x| x.name == snip.name }.sort { |a,b| b.version.to_i <=> a.version.to_i }
  end

  # returns all of the current snips that match a search query
  #
  # case in-sensitive
  #
  # by default, searches a Snip's tags, name, and description, but any 
  # method on Snip can be queried
  #
  #     @repo.search 'interesting', :include => [ :changelog, :description ]
  #     
  # by default, only searches current snips, but you can search all by:
  #
  #    @repo.search 'neat', :all => true
  #
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

  # returns text for snips.index[.Z]
  def index
    all_snips.inject(''){ |all,snip| all << (snip.filename + "\n") }
  end

  # returns text for snips.yaml[.Z]
  def yaml
    require 'yaml'
    all_snips.to_yaml
  end

  def remote?
    Snip::Repo.is_remote? @location
  end
  def local?
    Snip::Repo.is_local? @location
  end

  def self.is_remote? location
    not location.downcase[/^http/].nil?
  end
  def self.is_local? location
    not is_remote? location
  end

end
