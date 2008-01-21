class Object
  def require? lib
    begin
      require lib
      true
    rescue LoadError
      false
    end
  end
end
