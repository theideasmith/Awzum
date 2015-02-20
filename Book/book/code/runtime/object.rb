class AwesomeObject  
  # Each object has a class (named <code>runtime_class</code> to prevent conflicts
  # with Ruby's <code>class</code> keyword).
  # Optionally an object can hold a Ruby value. Eg.: numbers and strings will store their
  # number or string Ruby equivalent in that variable.
  attr_accessor :runtime_class, :ruby_value

  def initialize(runtime_class, ruby_value=self)
    @runtime_class = runtime_class
    @ruby_value = ruby_value
  end

  # Like a typical Class-based runtime model, we store methods in the class of the
  # object. When calling a method on an object, we need to first lookup that
  # method in the class, and then call it.
  def call(method, arguments=[])
    @runtime_class.lookup(method).call(self, arguments)
  end
end