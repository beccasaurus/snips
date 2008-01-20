# extend Hash to be 'indifferent' to make config variables easy
# ( borrowed from Camping [http://code.whytheluckystiff.net/camping/] )
#
# and with reverse_merge and assert_valid_keys for 'named arguments'
# ( borrowed from active_support )
class Hash
  def method_missing(m,*a)
    m.to_s =~ /=$/ ? (self[$`] = a[0]) : (a==[] ? self[m.to_s] : super)
  end
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end
  def reverse_merge!(other_hash)
    replace(reverse_merge(other_hash))
  end 
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty? 
  end
end
