class Token
	attr_accessor :token, :value 
	def initialize t, v
		@token =t
		@value=v 
	end
end


class Lexer
	KEYWORDS = ["def","class","if","else","elsif","while","true","false","nil"]
	TOKENS = {
				id: /\A([a-z]\w*)/,
				constant: /\A([A-Z]\w*)/,
				number: /\A([0-9]+)/,
				string: /\A"([^"]*)"/,
				block_start:/\A(\{)/,
				block_end:/\A(\})/,
				indent_tabs: /\:\n( +)/m,
				indent_spaces:/\A\n( *)/m,
				operator: /\A(\|\||&&|==|!=|<=|>=|<|>)/,
				space: /\A /,
				other: /\A./
			}
	

	def tokenize code
		code.chomp! #Removing all newline characters and other ugly parts of the string we dont really like. 
		tokens = []

		scope = 0
		indent_stack = []

		block_forward = 0
		block_backward = 0

		index = 0
		until index == code.size
			puts code[index]
			codon = code[index..-1] #Biology class is getting the best of me
			vars = {}
			if id = codon[/\A([a-z]\w*)/,1]
				if KEYWORDS.include?(id)
					vars = {token: id.upcase.to_sym, value:id, jump:id.size}
				else
					vars = {token: :IDENTIFIER,value:id, jump:id.size}
				end
			elsif constant = codon[/\A([A-Z]\w*)/,1]
				vars = {token: :CONSTANT,value:constant, jump:constant.size}
			elsif number = codon[/\A([0-9]+)/,1]
				vars = {token: :NUMBER,value:number.to_i, jump:number.size}
			
			elsif string = codon[/\A"([^"]*)"/,1]
				vars = {token: :STRING,value:string, jump:string.size+2}

			# elsif block_start = codon[TOKENS[:block_start],1]
			# 	block_forward+=1
			# 	var = {token: :BLOCK_BEGIN,value:"{",jump:1}
			
			# elsif block_end = codon[TOKENS[:block_end],1]
			# 	block_backward+=1
			# 	var = {token: :BLOCK_END,value:"}",jump:1}
			# 	raise "Extraneous closing brace - } -  " if block_backward > block_forward
			# 	raise "Expecting }" if block_backward < block_forward
			elsif indent = codon[/\:\n( +)/m,1]
				 # indent increases when hitting block
				if indent.size <= scope
				 	raise "Bad indent level, got #{indent.size} indents, expected > #{scope}"
	            end
	            scope = indent.size 
	            indent_stack.push(scope)
	            vars = {token: :INDENT,value:indent.size, jump:indent.size+2}
			elsif indent = codon[/\A\n( *)/m,1]

				if indent.size == scope
					vars = {token: :NEWLINE, value:"\n", jump:0}

				elsif indent.size < scope
					 while indent.size < scope
			            indent_stack.pop
			            scope = indent_stack.last || 0
			            tokens << [:DEDENT, indent.size]
			          end
			          tokens << [:NEWLINE, "\n"]
				else 
					raise "Missing ':'. Cannot increase indent level from #{scope} to #{indent.size} without ':' "
				end
				index+=(indent_spaces.size+1)
			elsif operator = codon[/\A(\|\||&&|==|!=|<=|>=)/,1]
				vars = {token: operator,value:operator, jump:operator.size}
			
			elsif space = codon.match(/\A /)
				index+=1
			else 
				operator_other = codon[0,1]
				vars = {token: operator_other,value:operator_other, jump: 1}
			
			end
			tokens << [vars[:token],vars[:value]] if vars[:token] && vars[:value]
			index+= vars[:jump] if vars[:jump]# Token.new(vars[:token],vars[:value]) 

			while scope = indent_stack.pop
				tokens << [:DEDENT,(indent_stack.first || 0)] #Token.new(:DEDENT, indent_stack.first || 0)
			end

		end
		puts tokens.inspect
		tokens
	end
end
 code = "Hello"

puts Lexer.new.tokenize(code).inspect



