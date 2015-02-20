	TOKENS = {
				id: /([a-z]\w*)/,
				constant: /([A_Z]+)/,
				number: /([0-9]+)/,
				string: /"([^"]*)"/,
				indent_tabs: /\:\n( +)/m,
				indent_spaces:/\n( *)/m
			}

puts TOKENS.keys
puts TOKENS.keys.include? :id