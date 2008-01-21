# make a class act like an indifferent hash with a static 'variables' hash
module IndifferentVariableHash
    attr_accessor :variables
    alias vars variables ; alias :vars= :variables=

    def method_missing name, *a
      begin
        self.variables.send name, *a
      rescue
        super
      end
    end
end
