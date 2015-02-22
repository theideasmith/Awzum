require "./Unit_Test_Helper.rb"
require_relative '../src/shunting_yard.rb'

class LexerTest < Test::Unit::TestCase
	def test_simpleaddition
		assert_equal [3,4,"+"], Shunt.eval("3+4")
	end
end