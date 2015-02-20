# Our lexer will be used like so: `Lexer.new.tokenize("code")`,
# and will return an array of tokens (a token being a tuple of `[TOKEN_TYPE, TOKEN_VALUE]`).
class Lexer
  # First we define the special keywords of our language in a constant.
  # It will be used later on in the tokenizing process to disambiguate
  # an identifier (method name, local variable, etc.) from a keyword.
  KEYWORDS = ["def", "class", "if", "true", "false", "nil"]
  
  def tokenize(code)
    code.chomp! # Remove extra line breaks
    tokens = [] # This will hold the generated tokens
    
    # We need to know how deep we are in the indentation so
    # we keep track of the current indentation level we are in, and previous ones in the stack
    # so that when we dedent, we can check if we're on the correct level.
    current_indent = 0 # number of spaces in the last indent
    indent_stack = []
    
    # Here is how to implement a very simple scanner.
    # Advance one character at the time until you find something to parse.
    # We'll use regular expressions to scan from the current position (`i`)
    # up to the end of the code.
    i = 0 # Current character position
    while i < code.size
      chunk = code[i..-1]
      
      # Each of the following `if/elsif`s will test the current code chunk with
      # a regular expression. The order is important as we want to match `if`
      # as a keyword, and not a method name, we'll need to apply it first.
      #
      # First, we'll scan for names: method names and variable names, which we'll call identifiers.
      # Also scanning for special reserved keywords such as `if`, `def`
      # and `true`.
      if identifier = chunk[/\A([a-z]\w*)/, 1]
        if KEYWORDS.include?(identifier) # keywords will generate [:IF, "if"]
          tokens << [identifier.upcase.to_sym, identifier]
        else
          tokens << [:IDENTIFIER, identifier]
        end
        i += identifier.size # skip what we just parsed
      
      # Now scanning for constants, names starting with a capital letter.
      # Which means, class names are constants in our language.
      elsif constant = chunk[/\A([A-Z]\w*)/, 1]
        tokens << [:CONSTANT, constant]
        i += constant.size
        
      # Next, matching numbers. Our language will only support integers. But to add support for floats,
      # you'd simply need to add a similar rule and adapt the regular expression accordingly.
      elsif number = chunk[/\A([0-9]+)/, 1]
        tokens << [:NUMBER, number.to_i]
        i += number.size
        
      # Of course, matching strings too. Anything between `"..."`.
      elsif string = chunk[/\A"([^"]*)"/, 1]
        tokens << [:STRING, string]
        i += string.size + 2 # skip two more to exclude the `"`.
      
      # And here's the indentation magic! We have to take care of 3 cases:
      # 
      #     if true:  # 1) The block is created.
      #       line 1
      #       line 2  # 2) New line inside a block, at the same level.
      #     continue  # 3) Dedent.
      #
      # This `elsif` takes care of the first case. The number of spaces will determine 
      # the indent level.
      elsif indent = chunk[/\A\:\n( +)/m, 1] # Matches ": <newline> <spaces>"
        if indent.size <= current_indent # indent should go up when creating a block
          raise "Bad indent level, got #{indent.size} indents, " +
                "expected > #{current_indent}"
        end
        current_indent = indent.size
        indent_stack.push(current_indent)
        tokens << [:INDENT, indent.size]
        i += indent.size + 2
  
      # The next `elsif` takes care of the two last cases:
      #
      # * Case 2: We stay in the same block if the indent level (number of spaces) is the
      #   same as `current_indent`.
      # * Case 3: Close the current block, if indent level is lower than `current_indent`.
      elsif indent = chunk[/\A\n( *)/m, 1] # Matches "<newline> <spaces>"
        if indent.size == current_indent # Case 2
          tokens << [:NEWLINE, "\n"] # Nothing to do, we're still in the same block
        elsif indent.size < current_indent # Case 3
          while indent.size < current_indent
            indent_stack.pop
            current_indent = indent_stack.last || 0
            tokens << [:DEDENT, indent.size]
          end
          tokens << [:NEWLINE, "\n"]
        else # indent.size > current_indent, error!
          raise "Missing ':'" # Cannot increase indent level without using ":"
        end
        i += indent.size + 1
      
      # Long operators such as `||`, `&&`, `==`, etc.
      # will be matched by the following block.
      # One character long operators are matched by the catch all `else` at the bottom.
      elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/, 1]
        tokens << [operator, operator]
        i += operator.size
      
      # We're ignoring spaces. Contrary to line breaks, spaces are meaningless in our language.
      # That's why we don't create tokens for them. They are only used to separate other tokens.
      elsif chunk.match(/\A /)
        i += 1
      
      # Finally, catch all single characters, mainly operators.
      # We treat all other single characters as a token. Eg.: `( ) , . ! + - <`.
      else
        value = chunk[0,1]
        tokens << [value, value]
        i += 1
        
      end
      
    end
    
    # Close all open blocks. If the code ends without dedenting, this will take care of
    # balancing the `INDENT`...`DEDENT`s.
    while indent = indent_stack.pop
      tokens << [:DEDENT, indent_stack.first || 0]
    end
    
    tokens
  end
end
