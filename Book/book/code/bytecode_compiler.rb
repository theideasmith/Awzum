require "parser"

# The following code is structured almost exactly like `interpreter.rb`.
# The difference being that we won't evaluate the code on the spot,
# but generate byte-code that will achieve the same results when run
# inside the virtual machine (which is in fact a byte-code interpreter).
#
# `BytecodeCompiler` here is the same as `Interpreter`, a simple wrapper
# around the parser and the nodes `compile` method, with the addition of
# an `emit` method to help generate the bytecode.
class BytecodeCompiler
  def initialize
    @parser = Parser.new
    @bytecode = []
  end
  
  def compile(code)
    @parser.parse(code).compile(self)
    emit RETURN
    @bytecode
  end

  def emit(opcode, *operands) # Usage: emit OPCODE, operand1, operand2, ..., operandX
    @bytecode << opcode
    @bytecode.concat operands
  end
end

# Like in the interpreter, we reopen each node class supported by our
# compiler and add a `compile` method. Instead of passing an evaluation context,
# like in the interpreter, we pass the instance of `BytecodeCompiler` so that
# we can call its `emit` method to generate the byte-code.
class Nodes
  def compile(compiler)
    nodes.each do |node|
      node.compile(compiler)
    end
  end
end

class NumberNode
  def compile(compiler)
    compiler.emit PUSH_NUMBER, value
  end
end

# Remember how we implemented the `CALL` instruction in the VM? It expects
# two things on the stack when called: the receiver and the arguments.
# Compiling those will emit the proper bytecode, which will in turn push the
# proper values on the stack.
#
# One important thing to note about our compiler. Although it is very close to
# how a real compiler work, some parts have been simplified.
# Normally, we would not store the method name in the byte-code as is, but instead in a 
# literal table. Then we'd refer to that method using its index in the literal table.
#
# Eg.:  
# Literal table: `{ [0] 'print' }`  
# Instructions:  `CALL  0, 1`  (first operand being the index of 'print')
#
class CallNode
  def compile(compiler)
    if receiver
      receiver.compile(compiler)
    else
      compiler.emit PUSH_SELF # Default to self if no receiver
    end
    
    arguments.each do |argument| # Compile the arguments
      argument.compile(compiler)
    end

    compiler.emit CALL, method, arguments.size
  end
end
