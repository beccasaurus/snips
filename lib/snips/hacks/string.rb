class String
  # for cleaning up dirty strings like: a, b c d; e f , g ...
  # and getting back a unique list
  def to_list
    self.gsub( /[\/,;\:#]/ , ' ').gsub( '\\', '' ).split.uniq
  end
end
