# The first type is responsible for holding a collection of nodes,
# each one representing an expression. You can think of it as the internal
# representation of a block of code.
#
# Here we define nodes as Ruby classes that inherit from a `Struct`. This is a
# simple way, in Ruby, to create a class that holds some attributes (values).
# It is almost equivalent to:
# 
#     class Nodes
#       def initialize(nodes)
#         @nodes = nodes
#       end
#
#       def nodes
#         @nodes
#       end
#     end
#
#     n = Nodes.new("this is stored @nodes")
#     n.nodes # => "this is stored @nodes"
#
# But Ruby's `Struct` takes care of overriding the `==` operator for us and a bunch of
# other things that will make testing easier.
class Nodes < Struct.new(:nodes)
  def <<(node) # Useful method for adding a node on the fly.
    nodes << node
    self
  end
end

# Literals are static values that have a Ruby representation. For example, a string, a number, 
# `true`, `false`, `nil`, etc. We define a node for each one of those and store their Ruby
# representation inside their `value` attribute.
class LiteralNode < Struct.new(:value); end

class NumberNode < LiteralNode; end

class StringNode < LiteralNode; end

class TrueNode < LiteralNode
  def initialize
    super(true)
  end
end

class FalseNode < LiteralNode
  def initialize
    super(false)
  end
end

class NilNode < LiteralNode
  def initialize
    super(nil)
  end
end

# The node for a method call holds the `receiver`,
# the object on which the method is called, the `method` name and its
# arguments, which are other nodes.
class CallNode < Struct.new(:receiver, :method, :arguments); end

# Retrieving the value of a constant by its `name` is done by the following node.
class GetConstantNode < Struct.new(:name); end

# And setting its value is done by this one. The `value` will be a node. If we're
# storing a number inside a constant, for example, `value` would contain an instance
# of `NumberNode`.
class SetConstantNode < Struct.new(:name, :value); end

# Similar to the previous nodes, the next ones are for dealing with local variables.
class GetLocalNode < Struct.new(:name); end

class SetLocalNode < Struct.new(:name, :value); end

# Each method definition will be stored into the following node. It holds the `name` of the method,
# the name of its parameters (`params`) and the `body` to evaluate when the method is called, which
# is a tree of node, the root one being a `Nodes` instance.
class DefNode < Struct.new(:name, :params, :body); end

# Class definitions are stored into the following node. Once again, the `name` of the class and
# its `body`, a tree of nodes.
class ClassNode < Struct.new(:name, :body); end

# `if` control structures are stored in a node of their own. The `condition` and `body` will also
# be nodes that need to be evaluated at some point.
# Look at this node if you want to implement other control structures like `while`, `for`, `loop`, etc.
class IfNode  < Struct.new(:condition, :body); end