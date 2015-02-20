require "parser"
require "runtime"

# First, we create an simple wrapper class to encapsulate the interpretation process.
# All this does is parse the code and call `eval` on the node at the top of the AST.
class Interpreter
  def initialize
    @parser = Parser.new
  end
  
  def eval(code)
    @parser.parse(code).eval(RootContext)
  end
end

# The `Nodes` class will always be at the top of the AST. Its only purpose it to
# contain other nodes. It correspond to a block of code or a series of expressions.
# 
# The `eval` method of every node is the "interpreter" part of our language.
# All nodes know how to evalualte themselves and return the result of their evaluation.
# The `context` variable is the `Context` in which the node is evaluated (local
# variables, current self and current class).
class Nodes
  def eval(context)
    return_value = nil
    nodes.each do |node|
      return_value = node.eval(context)
    end
    return_value || Constants["nil"] # Last result is return value (or nil if none).
  end
end

# We're using `Constants` that we created before when bootstrapping the runtime to access
# the objects and classes from inside the runtime.
#
# Next, we implement `eval` on other node types. Think of that `eval` method as how the
# node bring itself to life inside the runtime.
class NumberNode
  def eval(context)
    Constants["Number"].new_with_value(value)
  end
end

class StringNode
  def eval(context)
    Constants["String"].new_with_value(value)
  end
end

class TrueNode
  def eval(context)
    Constants["true"]
  end
end

class FalseNode
  def eval(context)
    Constants["false"]
  end
end

class NilNode
  def eval(context)
    Constants["nil"]
  end
end

class GetConstantNode
  def eval(context)
    Constants[name]
  end
end

class GetLocalNode
  def eval(context)
    context.locals[name]
  end
end

# When setting the value of a constant or a local variable, the `value` attribute
# is a node, created by the parser. We need to evaluate the node first, to convert
# it to an object, before storing it into a variable or constant.
class SetConstantNode
  def eval(context)
    Constants[name] = value.eval(context)
  end
end

class SetLocalNode
  def eval(context)
    context.locals[name] = value.eval(context)
  end
end

# The `CallNode` for calling a method is a little more complex. It needs to set the receiver
# first and then evaluate the arguments before calling the method.
class CallNode
  def eval(context)
    if receiver
      value = receiver.eval(context)
    else
      value = context.current_self # Default to `self` if no receiver.
    end
    
    evaluated_arguments = arguments.map { |arg| arg.eval(context) }
    value.call(method, evaluated_arguments)
  end
end

# Defining a method, using the `def` keyword, is done by adding a method to the current class.
class DefNode
  def eval(context)
    method = AwesomeMethod.new(params, body)
    context.current_class.runtime_methods[name] = method
  end
end

# Defining a class is done in three steps:
#
# 1. Reopen or define the class.
# 2. Create a special context of evaluation (set `current_self` and `current_class` to the new class).
# 3. Evaluate the body of the class inside that context.
#
# Check back how `DefNode` was implemented, adding methods to `context.current_class`. Here is
# where we set the value of `current_class`.
class ClassNode
  def eval(context)
    awesome_class = Constants[name] # Check if class is already defined
    
    unless awesome_class # Class doesn't exist yet
      awesome_class = AwesomeClass.new
      Constants[name] = awesome_class # Define the class in the runtime
    end
    
    class_context = Context.new(awesome_class, awesome_class)
    body.eval(class_context)
    
    awesome_class
  end
end

# Finally, to implement `if` in our language,
# we turn the condition node into a Ruby value to use Ruby's `if`.
class IfNode
  def eval(context)
    if condition.eval(context).ruby_value
      body.eval(context)
    else # If no body is evaluated, we return nil.
      Constants["nil"]
    end
  end
end
