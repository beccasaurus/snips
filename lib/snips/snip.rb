#
# Represents a single 'snip'
#
class Snip
  meta_include IndifferentVariableHash
  eval "self.variables ||= {}"
  
  # attributes read from file ( name and content)
  attr_accessor :name, :version, :full_source

  # attributes read from file's email-style headers
  attr_accessor :author, :tags, :description, :dependencies, :date, :changelog

  # regex to match snip filenames [name,version]
  self.file_regex        = /(.*)\.([\d]{0,10})\.\w{0,4}/
  
  # valid email-style headers for snip files
  self.valid_headers     = %w( author changelog date dependencies description tags )

  # headers that allow more than one line of content ( other headers only parse the line they're on )
  self.multiline_headers = %w( changelog description )

  # attributes to include when getting a snip's 'info'
  self.info_attributes   = %w( name version author description tags )

  # attributes to include for Snip#to_yaml
  self.yaml_attributes   = %w( name version author tags description dependencies date changelog )

  # don't include the full_source when we Snip#to_yaml
  def to_yaml_properties
    self.yaml_attributes.collect { |x| "@#{x}" }
  end

  def initialize file_or_text = nil
    if File.file?file_or_text
      @full_source = File.read file_or_text
      name_parts   = Snip.file_regex.match File.basename( file_or_text )
      @name        = name_parts[1] if name_parts
      @version     = name_parts[2] if name_parts
    else
      @full_source = file_or_text
    end
    
    set_defaults
    parse
  end

  def set_defaults
    @tags         = []
    @dependencies = []
  end

  def filename
    "#{name}.#{version}.rb"
  end

  def source
    @full_source[/\n^[^#].*/m]
  end

  def header
    @full_source.gsub /\n^[^#].*/m , ''
  end

  def header_vars
    return @header_vars if @header_vars
      
    @header_vars = {}
    current_header_var = nil

    header.each_line do |line|
      
      line = line.chomp.gsub /^#/, ''
      match = /^[\s]?(\w+):(.*)$/.match line
      
      if match
        current_header_var               = match[1].strip.downcase
        @header_vars[current_header_var] = match[2].strip  
      elsif not current_header_var.nil?
        @header_vars[current_header_var] << ( "\n" + line ) if Snip.multiline_headers.include?current_header_var
      end

    end

    valid_vars = {}
    Snip.valid_headers.each do |var|
      valid_vars[var] = header_vars[var] if header_vars.keys.include?var
    end

    @header_vars = valid_vars
    @header_vars
  end

  def info
    text = ''
    Snip.info_attributes.each do |var|
      value = instance_variable_get "@#{var}"
      text << "#{var}: #{' ' * (15 - var.length)} #{ value }\n" if value
    end
    text
  end

  def author_name
    author ? author.gsub( /<(.*)>/, '' ).strip : nil
  end

  def author_email
    match = /<(.*)>/.match(author)
    match ? match[1] : nil
  end

  def changelog_summary
    changelog ? changelog.strip[/.*/] : nil
  end

  def parse
    Snip.valid_headers.each do |var|
      instance_variable_set "@#{var}", header_vars[var] if header_vars.keys.include?var
    end
    @dependencies = @dependencies.gsub( /[,;\/\:#]/ , ' ').split if @dependencies and @dependencies.is_a?String
    @tags = @tags.gsub( /[,;\/\:#]/ , ' ').split if @tags and @tags.is_a?String
    @date = Time.parse @date if @date and @date.is_a?String
  end

  def self.parse obj
    return ( obj.to_s.strip.empty? ) ? nil : Snip.new( obj.to_s )
  end

end
