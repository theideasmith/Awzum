
class Token
  attr_accessor :token, :value
  def initialize t, value
    @token, @value = t, v
  end
end
class Lexer
  KEYWORDS = ["true","false","if","elsif","else","while","case","when","do","class","def","nil"]
    def tokenize(code)
    code.chomp! 
    tokens = [] # This is where generated tokens go
    current_indent = 0 
    indent_stack = []
   
    # bracket_start = 0
    # bracked_end   = 0 

    index = 0 # Current reading index
    while index < code.size
      codon = code[index..-1] # A codon of DNA, where DNA is the code and a codon is a chunk of it
=begin
    Note: I originally wrote my own code to do this where each matched regex corresponds to a lambda which makes
    the code more modular, but in the end I realized it just overcomplicated things 
    and so removed it. Then, I did a few things to make the code look nicer but they ended up also 
    causing more complications so I left the code as it was in the book. 
    From here and onwards, my strategy is to follow the book as closely as I can, learn from what the book does,
    and then implement a language COMPLETELY on my own using what I learned from following the book.
    Before I lead myself, I must follow someone else.   

    Note: Is it a bad idea to design this language where scope can be defined using both {} and indents, or should it just stick to one?
=end
      if identifier = codon[/\A([a-z]\w*)/, 1]
        if KEYWORDS.include?(identifier) 
          tokens << [identifier.upcase.to_sym, identifier]
        else
          tokens << [:IDENTIFIER, identifier]
        end
        index += identifier.size
      
     
      elsif constant = codon[/\A([A-Z]\w*)/, 1]
        tokens << [:CONSTANT, constant]
        index += constant.size
        
      elsif number = codon[/\A([0-9]+)/, 1]
        tokens << [:NUMBER, number.to_i]
        index += number.size
        
      elsif string = codon[/\A"([^"]*)"/, 1]
        tokens << [:STRING, string]
        index += string.size + 2 
      
    
      elsif indent = codon[/\A\:\n( +)/m, 1] 
        if indent.size <= current_indent 
          raise "Bad indent level, got #{indent.size} indents, " +
                "expected > #{current_indent}"
        end
        current_indent = indent.size
        indent_stack.push(current_indent)
        tokens << [:INDENT, indent.size]
        index += indent.size + 2

      elsif indent = codon[/\A\n( *)/m, 1] 
        if indent.size == current_indent 
          tokens << [:NEWLINE, "\n"] 
        elsif indent.size < current_indent 
          while indent.size < current_indent
            indent_stack.pop
            current_indent = indent_stack.last || 0
            tokens << [:DEDENT, indent.size]
          end
          tokens << [:NEWLINE, "\n"]
        else 
          raise "Missing ':'" 
        end
        index += indent.size + 1
      # elsif forward_brak = codon[/\A(\{ *\n *)/,1]
      #   bracket_start+=1
      #   token << [:START_BRACKET, forward_brak]
      #   index+=1
      # elsif backward_brak = codon[/\A( *\} *\n})/,1]
      #    bracket_end +=1
      #    raise "Extraneous closing brace" if bracket_end > bracket_start
      #    raised ""
      #    token << [:END_BRACKET, backward_brak]
      #    index += 1

      #    bracket_end-=1
      #    bracket_start-=1
      elsif operator = codon[/\A(\|\||&&|==|!=|<=|>=)/, 1]
        tokens << [operator, operator]
        index += operator.size
      
      elsif codon.match(/\A /)
        index += 1
    
      else
        value = codon[0,1]
        tokens << [value, value]
        index += 1
        
      end
      
    end
    while indent = indent_stack.pop
      tokens << [:DEDENT, indent_stack.first || 0]
    end
    
    # raise "Extraneous starting brace {"if bracket_start > bracket_end 

    tokens
  end
end
