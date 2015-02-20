require "test_helper"
require "vm"

# In case you didn't complete exercises in Runtime chapter.
# This is the solution.
Constants["Number"].def :+ do |receiver, arguments|
  result = receiver.ruby_value + arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end

class VMTest < Test::Unit::TestCase
  def test_run
    bytecode = [
      # opcode     operands      stack after     description
      # ------------------------------------------------------------------------
      PUSH_NUMBER, 1,          # stack = [1]     push 1, the receiver of "+"
      PUSH_NUMBER, 2,          # stack = [1, 2]  push 2, the argument for "+"
      CALL,        "+", 1,     # stack = [3]     call 1.+(2) and push the result
      RETURN                   # stack = []
    ]

    result = VM.new.run(bytecode)

    assert_equal 3, result.ruby_value
  end
end