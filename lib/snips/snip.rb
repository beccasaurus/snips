class Snip
  include IndifferentVariableHash

  def initialize file
    @variables = {}

    self.filename = File.basename file
    self.version  = self.filename[/-([\d\.]+)/]
    self.name, self.extension = *self.filename.split( self.version )
    self.version.sub!(/^-/,'').sub!(/\.$/,'')
    puts @variables.inspect

    File.read( file )
  end

end

=begin
  self.file_regex        = /(.*)\.([\d]{0,10})\.\w{0,4}/
  author ? author.gsub( /<(.*)>/, '' ).strip : nil
  match = /<(.*)>/.match(author)
  match ? match[1] : nil
  changelog ? changelog.strip[/.*/] : nil
  list.gsub( /[\/,;\:#]/ , ' ').gsub( '\\', '' ).split.uniq
  def to_yaml_properties
  Snip.yaml_attributes.collect { |x| "@#{x}" }
  @full_source.gsub /\n^[^#].*/m , ''

  def header_vars
    return @header_vars if @header_vars
      
    @header_vars = {}
    current_header_var = nil

    header.each_line do |line|
      
      line = line.chomp.gsub /^#/, ''
      match = /^[\s]?([\w\s]\w+):(.*)$/.match line
      
      if match
        current_header_var               = match[1].strip.downcase
        @header_vars[current_header_var] = match[2].strip  
      elsif not current_header_var.nil?
        @header_vars[current_header_var] << ( "\n" + line ) if Snip.multiline_headers.include?current_header_var
      end

    end
    @header_vars
  end
=end
