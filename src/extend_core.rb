#Adding functionality to some of the core classes, mostly, as you can see, the String class. 

class String

	NUMBER_PATTERNS = [
			/^[1-9]([0-9]*)?\.[0-9]+/,
			/^[1-9]([0-9]*)?/, # decimal
			/^0[0-7]+/,             # octal
			/^0x[0-9A-Fa-f]+/,      # hexadecimal
			/^0b[01]+/
		]

	def match_any? array #Does self match any of the regexpressions in the array
		return true if shift_match_any array
		false 
	end

	def match_first_in array
		begin 
		array.each do |i|
				regexp = if i.class == Regexp
					i
				elsif i.class == String 
					Regexp::new i
				else 
					raise "Type mismatch. Required #{String} or #{Regexp}, but got #{i.class}."
				end
				ind = self =~ regexp
				if (match = self[i]) && (ind == 0)
					return match
				end

		end
		rescue => err
			puts err
		end
	end

	def match_first string
		if string.class == Regexp
			return	self.scan(string)[0]
		else
			return self.scan(Regexp::new(string))[0]
		end

	end
	def integer?
		[                          # In descending order of likeliness:
			/^[-+]?[1-9]([0-9]*)?$/, # decimal
			/^0[0-7]+$/,             # octal
			/^0x[0-9A-Fa-f]+$/,      # hexadecimal
			/^0b[01]+$/              # binary
		].each do |match_pattern|
			return true if self =~ match_pattern
		end
		return false
	end

	def float?
		pat = /^[-+]?[1-9]([0-9]*)?\.[0-9]+$/
		return true if self=~pat 
		false 
	end

	#Is self a false or an int. Should later add support for all types of numbers
	def number?
		return true if self.float? 
		return true if self.integer?
		false
	end

	#The numberified version of self. If I'm a float, return me as a float. If I'm a 
	def to_n
		return self.to_f if self.float?

		return self.to_i if self.integer? 
	end

	#Returns the first number to be found in self. 
	def shift_number
		NUMBER_PATTERNS.each do |match_pattern|
			if match = self[match_pattern] #Interesting way of doing if statements. I learned it from the programming language book and am hooked. 
				return match
			end
		end
		nil
	end


end
