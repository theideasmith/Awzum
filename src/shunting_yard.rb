require 'readline'
require_relative './extend_core.rb'

# puts "Welcome to Shunting Yard - the algorithm" #If you are using it as a standalone program

class Operator 
	attr_accessor :associativity, :precedence
end

def op asos, prec
	x = Operator.new 
	x.associativity = asos
	x.precedence    = prec

	x
end
class Shunt

	:left_associative # Using the following two as an "anonymous" enum. 
	:right_associative






	OPERATORS = {
		"+" => op(:left_associative,1),
		"-" => op(:left_associative,1),
		"*" => op(:left_associative,2),
		"/" => op(:left_associative,2),
		"^" => op(:right_associative,5)
	}
	OPERATOR = /(^[\+\-\*\\\^])/

	FUNCTIONS = ["cos","sin","tan","arctan","arccos","arcsin","sqrt","log2","log10","log"]
	FUNCTION = /[a-z]+/

	FUNCTION_ARG_SEPARATOR = /[\,]/


=begin
	Thanks to http://en.wikipedia.org/wiki/Shunting-yard_algorithm for helping me out
	Shunting yard converts  expressiong in infix notation to RPN or Reverse Polish Notation. So 3,^,4,+,5  becomes 3,4,^,5,+
	The time complexity for the shunting yard algorithm is O(n)

	Here's why it works:

	Numbers automatically get pushed to output.

	Let Op1 be the currently being evaluated operator, and Op2 the operator at the top of the operator stack

	Operators with higher precedence need to be evaluated first, so they are immediately pushed onto the output stack in every case.
	Left associative operators, Op2, are pushed to the output stack if they are MORE THAN and EQUAL TO the currently being evaluated operator Op1:
		 because left associative operators are bound to numbers that have previously been pushed to the output stack 
		 - thus these numbers necessitate that their operators be placed near to them

	Right associative operators, Op2 are only pushed to the stack ONLY if they have HIGHER PRECEDANCE than Op1
		because right associative operators split an expression in half and can only be pushed if they have a HIGHER precedence. 
		If they were pushed with an equal precedence, it would betrey the fact that they divide an expression in half:
		
			Given 3^4^5^6 or 3 ^ (4^(5^6)) (Notice how expression is divided by the "^"?) => RPN:   3(4 (5 6 ^) ^ )^
			If you immediately pushed the ^ operator to the output queue when it has equal precedence, 
			then the RVM of the expression would be: 3 4 ^ 5 6 ^ ^, which is not correct. 

		A right associative operator that comes before another instance of itself in an expression has a higher precedence than the second instance of itself.  
		Everything after a "^" is included in a different scope(see expression above), which is why the "^" cannot be released to the output queue. It applies to the ENTIRE scope after itself. 

		I hope this was a good explanation for the reasons behind which operators go where in the shunting yard algorithm. 
		

=end
	def self.eval string
	  	operator_stack = []
	  	output = []

	  	i = 0
	  	while i < string.size
	  		
	  		chunk = string[i..-1]
	  		if num = chunk.shift_number
	  			i+=num.size
	  			output << num.to_n
		  	elsif chunk[0] == " "
		  		i+=1
	  		elsif op1_char = chunk[OPERATOR,1]

	  			op1 = OPERATORS[op1_char]
	  			op2 = OPERATORS[operator_stack.last]
	  			cond1 =  ((op1.associativity == :left_associative) && (op1.precedence <= op2.precedence)) if op2
		  		cond2 =  ((op1.associativity == :right_associative) && (op1.precedence < op2.precedence)) if op2
	  	  		while op2 && (cond1 || cond2)  #While the first character in array is an operator
		  			output << operator_stack.pop 

		  			op2   = OPERATORS[operator_stack.last]
		  			cond1 =  ((op1.associativity == :left_associative) && (op1.precedence <= op2.precedence)) if op2
		  			cond2 =  ((op1.associativity == :right_associative) && (op1.precedence < op2.precedence)) if op2
		  		end

		  		i+=op1_char.size
		  		operator_stack << op1_char #Push op1 onto operator stack for further evaluation
		  	elsif (chunk =~ FUNCTION) ==0
		  		func = chunk.match_first(FUNCTION)
		  		output << func
		  		i+=func.size
		  	elsif (chunk =~ FUNCTION_ARG_SEPARATOR) ==0
				j = 0
				found = false
		  		until (operator_stack[j] == "(") || j==operator_stack.size
		  			output << operator_stack.pop
		  			j+=1
		  		end
		  		found = true if operator_stack[j] == "("
		  		raise "Mismatched parenthesis or misplaced function arg separator" unless found
		  		i+=1
		  	elsif paren_left = chunk["("]
		  		i+=1
		  		operator_stack << "("	
		  	elsif chunk[0] == ")"
				j = 0
		  		until (j >= operator_stack.size) || (operator_stack.last == "(")
		  			output << operator_stack.pop
		  			j+=1
		  		end

		  		left_paren = operator_stack.pop
		  		output << operator_stack.pop if operator_stack[0] =~ /[a-z]+/
		  		raise "Unmatched (" unless left_paren
		  		i+=1

		  	else 
		  		raise "Could not parse operator:#{i}: #{chunk}"
	  		end

	  	end

	  	while op = operator_stack.pop
	  		raise "Mismatched parenthesis" if op == ("(" || ")")
	  		output << op
	  	end	
	  	output
	  
	end

	def repl
		while buf = Readline.readline(">>", true)
			puts Shunt.eval(buf).inspect
		end
	end

end