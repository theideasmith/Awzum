class AwesomeClass < AwesomeObject
  # Classes are objects in Awesome so they inherit from AwesomeObject.
  
  attr_reader :runtime_methods

  def initialize
    @runtime_methods = {}
    @runtime_class = Constants["Class"]
  end

  # Lookup a method
  def lookup(method_name)
    method = @runtime_methods[method_name]
    raise "Method not found: #{method_name}" if method.nil?
    method
  end

  # Helper method to define a method on this class from Ruby.
  def def(name, &block)
    @runtime_methods[name.to_s] = block
  end

  # Create a new instance of this class
  def new
    AwesomeObject.new(self)
  end
  
  # Create an instance of this Awesome class that holds a Ruby value. Like a String, 
  # Number or true.
  def new_with_value(value)
    AwesomeObject.new(self, value)
  end
end