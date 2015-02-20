class Parser

# We need to tell the parser what tokens to expect. So each type of token produced
# by our lexer needs to be declared here.
token IF
token DEF
token CLASS
token NEWLINE
token NUMBER
token STRING
token TRUE FALSE NIL
token IDENTIFIER
token CONSTANT
token INDENT DEDENT

# Here is the Operator Precedence Table. As presented before, it tells the parser in
# which order to parse expressions containing operators.
# This table is based on the [C and C++ Operator Precedence Table](http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence).
prechigh
  left  '.'
  right '!'
  left  '*' '/'
  left  '+' '-'
  left  '>' '>=' '<' '<='
  left  '==' '!='
  left  '&&'
  left  '||'
  right '='
  left  ','
preclow

# In the following `rule` section, we define the parsing rules.
# All rules are declared using the following format:
#
#     RuleName:
#       OtherRule TOKEN AnotherRule    { result = Node.new }
#     | OtherRule                      { ... }
#     ;
#
# In the action section (inside the `{...}` on the right), you can do the following:
#
# * Assign to `result` the value returned by the rule, usually a node for the AST.
# * Use `val[index of expression]` to get the `result` of a matched
#   expressions on the left.
rule
  # First, parsers are dumb, we need to explicitly tell it how to handle empty
  # programs. This is what the first rule does. Note that everything between `/* ... */` is
  # a comment.
  Program:
    /* nothing */                      { result = Nodes.new([]) }
  | Expressions                        { result = val[0] }
  ;
  
  # Next, we define what a list of expressions is. Simply put, it's series of expressions separated by a
  # terminator (a new line or `;` as defined later). But once again, we need to explicitly
  # define how to handle trailing and orphans line breaks (the last two lines).
  #
  # One very powerful trick we'll use to define variable rules like this one
  # (rules which can match any number of tokens) is *left-recursion*. Which means we reference
  # the rule itself, directly or indirectly, on the left side **only**. This is true for the current
  # type of parser we're using (LR). For other types of parsers like ANTLR (LL), it's the opposite,
  # you can only use right-recursion.
  #
  # As you'll see bellow, the `Expressions` rule references `Expressions` itself.
  # In other words, a list of expressions can be another list of expressions followed by
  # another expression.
  Expressions:
    Expression                         { result = Nodes.new(val) }
  | Expressions Terminator Expression  { result = val[0] << val[2] }
  | Expressions Terminator             { result = val[0] }
  | Terminator                         { result = Nodes.new([]) }
  ;

  # Every type of expression supported by our language is defined here.
  Expression:
    Literal
  | Call
  | Operator
  | GetConstant
  | SetConstant
  | GetLocal
  | SetLocal
  | Def
  | Class
  | If
  | '(' Expression ')'    { result = val[1] }
  ;

  # Notice how we implement support for parentheses using the previous rule. 
  # `'(' Expression ')'` will force the parsing of `Expression` in its
  # entirety first. Parentheses will then be discarded leaving only the fully parsed expression.
  #
  # Terminators are tokens that can terminate an expression.
  # When using tokens to define rules, we simply reference them by their type which we defined in
  # the lexer.
  Terminator:
    NEWLINE
  | ";"
  ;
  
  # Literals are the hard-coded values inside the program. If you want to add support
  # for other literal types, such as arrays or hashes, this it where you'd do it.
  Literal:
    NUMBER                        { result = NumberNode.new(val[0]) }
  | STRING                        { result = StringNode.new(val[0]) }
  | TRUE                          { result = TrueNode.new }
  | FALSE                         { result = FalseNode.new }
  | NIL                           { result = NilNode.new }
  ;
  
  # Method calls can take three forms:
  #
  # * Without a receiver (`self` is assumed): `method(arguments)`.
  # * With a receiver: `receiver.method(arguments)`.
  # * And a hint of syntactic sugar so that we can drop
  #   the `()` if no arguments are given: `receiver.method`.
  #
  # Each one of those is handled by the following rule.
  Call:
    IDENTIFIER Arguments          { result = CallNode.new(nil, val[0], val[1]) }
  | Expression "." IDENTIFIER
      Arguments                   { result = CallNode.new(val[0], val[2], val[3]) }
  | Expression "." IDENTIFIER     { result = CallNode.new(val[0], val[2], []) }
  ;

  Arguments:
    "(" ")"                       { result = [] }
  | "(" ArgList ")"               { result = val[1] }
  ;

  ArgList:
    Expression                    { result = val }
  | ArgList "," Expression        { result = val[0] << val[2] }
  ;
  

  # In our language, like in Ruby, operators are converted to method calls.
  # So `1 + 2` will be converted to `1.+(2)`.
  # `1` is the receiver of the `+` method call, passing `2`
  # as an argument.
  # Operators need to be defined individually for the Operator Precedence Table to take
  # action.
  Operator:
    Expression '||' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&&' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '==' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '!=' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  ;
  
  # Then we have rules for getting and setting values of constants and local variables.
  GetConstant:
    CONSTANT                      { result = GetConstantNode.new(val[0]) }
  ;
  
  SetConstant:
    CONSTANT "=" Expression       { result = SetConstantNode.new(val[0], val[2]) }
  ;

  GetLocal:
    IDENTIFIER                    { result = GetLocalNode.new(val[0]) }
  ;
  
  SetLocal:
    IDENTIFIER "=" Expression     { result = SetLocalNode.new(val[0], val[2]) }
  ;

  # Our language uses indentation to separate blocks of code. But the lexer took care of all
  # that complexity for us and wrapped all blocks in `INDENT ... DEDENT`. A block
  # is simply an increment in indentation followed by some code and closing with an equivalent
  # decrement in indentation.
  # 
  # If you'd like to use curly brackets or `end` to delimit blocks instead, you'd
  # simply need to modify this one rule.
  # You'll also need to remove the indentation logic from the lexer.
  Block:
    INDENT Expressions DEDENT     { result = val[1] }
  ;
  
  # The `def` keyword is used for defining methods. Once again, we're introducing
  # a bit of syntactic sugar here to allow skipping the parentheses when there are no parameters.
  Def:
    DEF IDENTIFIER Block          { result = DefNode.new(val[1], [], val[2]) }
  | DEF IDENTIFIER
      "(" ParamList ")" Block     { result = DefNode.new(val[1], val[3], val[5]) }
  ;

  ParamList:
    /* nothing */                 { result = [] }
  | IDENTIFIER                    { result = val }
  | ParamList "," IDENTIFIER      { result = val[0] << val[2] }
  ;
  
  # Class definition is similar to method definition.
  # Class names are also constants because they start with a capital letter.
  Class:
    CLASS CONSTANT Block          { result = ClassNode.new(val[1], val[2]) }
  ;
  
  # Finally, `if` is similar to `class` but receives a *condition*.
  If:
    IF Expression Block           { result = IfNode.new(val[1], val[2]) }
  ;
end

# The final code at the bottom of this Racc file will be put as-is in the generated `Parser` class.
# You can put some code at the top (`header`) and some inside the class (`inner`).
---- header
  require "lexer"
  require "nodes"

---- inner
  def parse(code, show_tokens=false)
    @tokens = Lexer.new.tokenize(code) # Tokenize the code using our lexer
    puts @tokens.inspect if show_tokens
    do_parse # Kickoff the parsing process
  end
  
  def next_token
    @tokens.shift
  end