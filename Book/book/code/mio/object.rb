module Mio
  class Object
    attr_accessor :slots, :proto, :value
    
    def initialize(proto=nil, value=nil)
      @proto = proto # Prototype: parent object. Like JavaScript's __proto__.
      @value = value # The Ruby equivalent value.
      @slots = {} # Slots are where we store methods and attributes of an object.
    end
    
    # Lookup a slot in the current object and proto.
    def [](name)
      return @slots[name] if @slots.key?(name)
      return @proto[name] if @proto # Check if parent prototypes
      raise Mio::Error, "Missing slot: #{name.inspect}"
    end
    
    # Store a value in a slot
    def []=(name, value)
      @slots[name] = value
    end
    
    # Store a method into a slot
    def def(name, &block)
      @slots[name] = block
    end
    
    # The call method is used to eval an object.
    # By default objects eval to themselves.
    def call(*args)
      self
    end
    
    # The only way to create a new object in Mio is to clone an existing one.
    def clone(ruby_value=nil)
      Object.new(self, ruby_value)
    end
  end
end