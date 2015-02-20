require "test_helper"
require "bytecode_compiler"
require "vm"

class BytecodeCompilerTest < Test::Unit::TestCase
  def test_compile
    bytecode = BytecodeCompiler.new.compile("print(1+2)")

    expected_bytecode = [
    #                          Generated bytecode
    #
    # opcode       operands      stack after           description
    # ------------------------------------------------------------------------------
      PUSH_SELF,               # stack = [self]        push the receiver of "print"
      PUSH_NUMBER, 1,          # stack = [1]
      PUSH_NUMBER, 2,          # stack = [self, 1, 2]  push the argument for "+"
      CALL,        "+", 1,     # stack = [self, 3]     call 1.+(2) and push the result
      CALL,        "print", 1, # stack = []            call self.print(3)
      RETURN
    ]

    # Make sure the compiler generates the previous bytecode.
    assert_equal expected_bytecode, bytecode

    # Make sure the VM can run that bytecode.
    assert_prints("3\n") { VM.new.run(bytecode) }
  end
end