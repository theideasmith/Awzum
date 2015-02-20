require 'set'
class Token
	attr_accessor :token, :value 
	def initialize t, v
		@token =t
		@value=v 
	end
end


class Lexer
	KEYWORDS = ["def","class","if","else","elsif","true","false","nil"]
	TOKENS = {
				id: /([a-z]+)/,
				constant: /([A-Z]+)/,
				number: /([0-9]+)/,
				string: /"([^"]*)"/,
				indent_tabs: /\:\n( +)/m,
				indent_spaces:/\n( *)/m,
				operator: /(\|\||&&|==|!=|<=|>=)/,
				space: /( +)/,
				other: /(.)+/
			}
	attr_accessor :token_operations, :indent, :indent_stack

	def initialize


		@token_operations = Hash.new
		@indent = 0
		@indent_stack = []
		#By storing the various reactions to regexs in a dictionary, it makes expanding the parser much easier and is one level below building a custom parser
		@token_operations[:id] = lambda do |regex, string, array|
			if match = string[regex,1]
				# puts "#{string}|#{match}|#{match.size}"

				if KEYWORDS.include? match
					array << Token.new(match.upcase.to_sym, match)
				else 
					array << Token.new(:IDENTIFIDER, match)
				end	
				return match.size
			end
			0
		end
		
		@token_operations[:constant] = lambda do |regex, string, array|
			if match = string[regex,1]
				array << Token.new(match.upcase.to_sym, match)
				return match.size
			end
			0
		end

		@token_operations[:number] = lambda do |regex, string, array|
			if match = string[regex,1]
				array << Token.new(match.upcase.to_sym, match)
				return match.size			
			end
			0
		end

		@token_operations[:string] = lambda do |regex, string, array|
			if match = string[regex,1]
				array << Token.new(match.upcase.to_sym, match)
				return match.size+2	
			end	
			0
		end
		
		@token_operations[:indent_tabs] = lambda do |regex, string, array|
			if match = string[regex,1]
				raise "Indent level inconsistent. Got #{match.size} >> expected #{@indent}" if match.size <= @indent
				@indent =match.size
				num = @indent
				@indent_stack.push num
				array << Token.new(match.upcase.to_sym, match)
				return match.size+2
			end
			0
		end
		@token_operations[:indent_spaces] = lambda do |regex, string, array|
			if match = string[regex,1]
				if match.size == @indent 
	              array << [:NEWLINE, "\n"] # Nothing to do, we're still in the same block
	            elsif match.size < @indent # Case 3
	              while match.size < @indent
	                @indent_stack.pop
	                @indent = @indent_stack.last || 0
	                array << [:DEDENT, match.size]
	              end
	              array << [:NEWLINE, "\n"]
	            else # indent.size > current_indent, error!
	              raise "Missing ':'" # Cannot increase indent level without using ":"
	            end
	            return match.size + 1
	        end
	        	 0
		end

		@token_operations[:operator] = lambda do |regex, string, array|
			if match = string[regex,1]
				array << [string, string]
				return match.size
			end
			0
		end

		@token_operations[:space] = lambda do |regex, string, array|
			return 1 if string.match regex #Will increment the current index in the code by 1
		end

		@token_operations[:other] =lambda do |regex, string, array|
			op = string[0,1]
	           array << Token.new(op.to_sym, op)
	        1 
		end
		raise "Token operations is not fitted to all availbale tokens:
		       Ops   : #{@token_operations.keys},
		       Tokens: #{TOKENS.keys}" unless (@token_operations.keys.to_set.subset? TOKENS.keys.to_set) 
	end

	def tokenize code
		code.chomp! #Removing all newline characters and other ugly parts of the string we dont really like. 
		tokens = []
		@indent = 0
		@indent_stack = []
		i = 0 #Current index of code being read
		while i < code.size #run through entire code
			puts "#{code[i]}"
			codon = code[i..-1]

			should_stop = false
			keys = TOKENS.keys
			ind = 0
			increment = 0
			until should_stop
				key = keys[ind]
				#----
				regex = TOKENS[key]
				method = @token_operations[key]
				#-----
				incr = method.call(regex, codon, tokens)
				if incr > 0
					should_stop = true
					increment = incr+1
				end
				ind+=1
			end
			i+=increment


			while @indent = @indent_stack.pop #Close any blocks that end without a dedent
       			tokens << [:DEDENT, @indent_stack.first || 0]
    		end 
		end
		tokens
	end
end

x = Lexer.new.tokenize(
"if x > 2:")


x.each {|i|puts i.inspect}



