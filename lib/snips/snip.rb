class Snip
  include IndifferentVariableHash
  def initialize file
    @variables = {}
    self.filename = File.basename file
    self.version  = self.filename[ /-([\d\.]+)/ ]
    self.name, self.extension = *self.filename.split( self.version )
    self.version.sub!( /^-/, '' ).sub!( /\.$/, '' )
    current_header = nil
    File.read( file ).gsub( /\n^[^#].*/m, '' ).each_line do |line|
      line = line.chomp.gsub /^#\s?/, ''
      if line.strip.empty?
        current_header = nil
      elsif ( match = /^[\s]?([\w\s]\w+):(.*)$/.match(line) )
        unless %w(name version filename).include? match[1].strip.downcase
          current_header = match[1].strip.downcase
          self.variables[  match[1].strip.downcase  ] = match[2].strip
        end
      elsif not current_header.nil?
        self.variables[  current_header  ] << "\n" unless self.variables[  current_header  ].strip.empty?
        self.variables[  current_header  ] << line
      end
    end
  end
end
