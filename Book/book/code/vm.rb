require "bytecode"
require "runtime"

class VM
  def run(bytecode)
    # First, we create the stack to pass values between instructions.
    # And initialize the Instruction Pointer (`ip`), the index of current instruction
    # being executed in `bytecode`.
    stack = []
    ip = 0
    
    # Next, we enter into the VM loop. Inside, we will advance one byte at the time
    # in the `bytecode`. The first byte will be an opcode.
    while true
      case bytecode[ip] # Inspect the current byte, this will be the opcode.

      # Each of the following `when` block handles one type of instruction.
      # They are all structured in the same way.
      #
      # The first instruction will push a number on the stack.
      when PUSH_NUMBER
        ip += 1 # Advance to next byte, the operand.
        value = bytecode[ip] # Read the operand.
        
        stack.push Constants["Number"].new_with_value(value)

      # Since calling methods on `self` is something we do often we have a special
      # instruction for pushing the value of `self` on the stack.
      when PUSH_SELF
        stack.push RootContext.current_self

      # The most complex instruction of our VM is `CALL`, for calling a method.
      # It has two operands and expects several things to be on the stack.
      when CALL
        ip += 1 # Next byte contains the method name to call.
        method = bytecode[ip]
        
        ip += 1 # Next byte, the number of arguments on the stack.
        argc = bytecode[ip]

        # At this point we assume arguments and the receiver of the method call
        # have been pushed to the stack by other instructions. For example, if
        # we were to call a method on `self` passing a number as an argument, we
        # would find those two on the stack. Now pop all of those.
        args = []
        argc.times do
          args << stack.pop
        end
        receiver = stack.pop

        # Using those values, we make the call exactly like we did in the interpreter
        # (`CallNode`'s `eval`).
        stack.push receiver.call(method, args)

      # Here is how we exit the VM loop. Each program must end with this instruction.
      when RETURN
        return stack.pop

      end
      
      # Finally, we move forward one more byte to the next operand, to prepare for the
      # next turn in the loop.
      ip += 1
    end
  end
end
