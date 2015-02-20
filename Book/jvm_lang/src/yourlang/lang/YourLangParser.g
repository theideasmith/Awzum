parser grammar YourLangParser;

options {
  output = AST; // Produce a tree of node
  tokenVocab = YourLangLexer; // Use tokens defined in our lexer.
  backtrack=true; // Resolve ambiguities by looking tokens ahead, slower but simpler.
}

// Stuff added on top of the Parser class.
@header {
  package yourlang.lang;
  
  import yourlang.lang.nodes.*;
  import java.util.ArrayList;
}

// Methods added to the Parser class.
@members {
  /**
    Run the parsing process and return the root node of the AST.
  */
  public Node parse() throws RecognitionException {
    root_return result = root();
    if (result == null) return null;
    return result.nodes;
  }
  
  // Override to throw exceptions on parse error.
  @Override
  public void reportError(RecognitionException e) {
    throw new RuntimeException(e);
  }
}

// Rethrow parsing error
@rulecatch {
  catch(RecognitionException recognitionException) {
    throw recognitionException;
  }
}

/*
  Format of a rule:
  
  ruleName returns [TypeOfNode nodeName]:
      // refer to values on the left using $.
      e=reference_to_other_rules      { $nodeName = $e; } // code executed when rule matches
    | other rules
    ;
  
  Value stored in $nodeName will be passed to the parent rule.
*/

// Top-level node of each AST
root returns [Nodes nodes]:
    terminator? expressions? EOF! { $nodes = $expressions.nodes; }
  ;

// Collection of nodes, often refered to as a body (methd body, class body, etc.)
expressions returns [Nodes nodes]:
                      { $nodes = new Nodes(); }
    head=expression   { $nodes.add($head.node); }
    (terminator
     tail=expression  { $nodes.add($tail.node); }
    )*
    terminator?
  ;

// A single expression
expression returns [Node node]:
    assignExpression      { $node = $assignExpression.node; }
  ;

// Anything that can terminate an expression.
terminator: (NEWLINE | SEMICOLON)+;

// To implement operator precedence, we use order of evaluation in the parser.
// First rules defined here are evaluated last.

// Assignation has the lowest precedence, evaluated last.
assignExpression returns [Node node]:
    assign                { $node = $assign.node; }
  | e=orExpression        { $node = $e.node; }
  ;

orExpression returns [Node node]:
    receiver=andExpression
      OR arg=orExpression       { $node = new OrNode($receiver.node, $arg.node); }
  | e=andExpression             { $node = $e.node; }
  ;

andExpression returns [Node node]:
    receiver=relationalExpression
      AND arg=andExpression     { $node = new AndNode($receiver.node, $arg.node); }
  | e=relationalExpression      { $node = $e.node; }
  ;

relationalExpression returns [Node node]:
    receiver=additiveExpression
      op=(EQ|LE|GE|LT|GT)
      arg=relationalExpression  { $node = new CallNode($op.text, $receiver.node, $arg.node); }
  | e=additiveExpression        { $node = $e.node; }
  ;

additiveExpression returns [Node node]:
    receiver=multiplicativeExpression
      op=(PLUS|MINUS) arg=additiveExpression  { $node = new CallNode($op.text, $receiver.node, $arg.node); }
  | e=multiplicativeExpression                { $node = $e.node; }
  ;

multiplicativeExpression returns [Node node]:
    receiver=unaryExpression
      op=(MUL|DIV|MOD) arg=multiplicativeExpression  { $node = new CallNode($op.text, $receiver.node, $arg.node); }
  | e=unaryExpression                                { $node = $e.node; }
  ;

unaryExpression returns [Node node]:
    NOT receiver=unaryExpression       { $node = new NotNode($receiver.node); }
  | e=primaryExpression                { $node = $e.node; }
  ;
// Highest precedence, evaluated first.

primaryExpression returns [Node node]:
    literal           { $node = $literal.node; }
  | call              { $node = $call.node; }
  | methodDefinition  { $node = $methodDefinition.node; }
  | classDefinition   { $node = $classDefinition.node; }
  | ifBlock           { $node = $ifBlock.node; }
  | whileBlock        { $node = $whileBlock.node; }
  | tryBlock          { $node = $tryBlock.node; }
  | OPEN_PARENT
      expression
    CLOSE_PARENT      { $node = $expression.node; }
  ;

// Any static value
literal returns [Node node]:
    STRING            { $node = new LiteralNode(new ValueObject($STRING.text.substring(1, $STRING.text.length() - 1))); }
  | INTEGER           { $node = new LiteralNode(new ValueObject(new Integer($INTEGER.text))); }
  | FLOAT             { $node = new LiteralNode(new ValueObject(new Float($FLOAT.text))); }
  | NIL               { $node = new LiteralNode(YourLangRuntime.getNil()); }
  | TRUE              { $node = new LiteralNode(YourLangRuntime.getTrue()); }
  | FALSE             { $node = new LiteralNode(YourLangRuntime.getFalse()); }
  | constant          { $node = $constant.node; }
  | instanceVariable  { $node = $instanceVariable.node; }
  | self              { $node = $self.node; }
  ;

// self
self returns [SelfNode node]:
    SELF              { $node = new SelfNode(); }
  ;

// Getting the value of an @instance_variable
instanceVariable returns [InstanceVariableNode node]:
    AT NAME           { $node = new InstanceVariableNode($NAME.text); }
  ;

// A method call
call returns [Node node]:
    (literal DOT                    { $node = $literal.node; }
      )?
    (head=message DOT               { ((CallNode)$head.node).setReceiver($node); $node = $head.node; }
      )*
    tail=message                    { ((CallNode)$tail.node).setReceiver($node); $node = $tail.node; }
  ;

// The tail part of a method call: method name + arguments
message returns [CallNode node]:
    NAME                            { $node = new CallNode($NAME.text); }
  | NAME OPEN_PARENT CLOSE_PARENT   { $node = new CallNode($NAME.text, new ArrayList<Node>()); }
  | NAME OPEN_PARENT
           arguments
         CLOSE_PARENT               { $node = new CallNode($NAME.text, $arguments.nodes); }
  ;

// Arguments of a method call.
arguments returns [ArrayList<Node> nodes]:
                                    { $nodes = new ArrayList<Node>(); }
    head=expression                 { $nodes.add($head.node); }
    (COMMA
     tail=expression                { $nodes.add($tail.node); }
    )*
  ;

// Getting the value of a Constant
constant returns [ConstantNode node]:
    CONSTANT                        { $node = new ConstantNode($CONSTANT.text); }
  ;

// Variable of constant assignation
assign returns [Node node]:
    NAME ASSIGN expression          { $node = new LocalAssignNode($NAME.text, $expression.node); }
  | CONSTANT ASSIGN expression      { $node = new ConstantAssignNode($CONSTANT.text, $expression.node); }
  | AT NAME ASSIGN expression       { $node = new InstanceVariableAssignNode($NAME.text, $expression.node); }
  ;

methodDefinition returns [MethodDefinitionNode node]:
    DEF NAME (OPEN_PARENT parameters? CLOSE_PARENT)? terminator
      expressions
    END                             { $node = new MethodDefinitionNode($NAME.text, $parameters.names, $expressions.nodes); }
  ;

// Parameters in a method definition.
parameters returns [ArrayList<String> names]:
                                    { $names = new ArrayList<String>(); }
    head=NAME                       { $names.add($head.text); }
    (COMMA
     tail=NAME                      { $names.add($tail.text); }
    )*
  ;

classDefinition returns [ClassDefinitionNode node]:
    CLASS name=CONSTANT (LT superClass=CONSTANT)? terminator
      expressions
    END                             { $node = new ClassDefinitionNode($name.text, $superClass.text, $expressions.nodes); }
  ;

ifBlock returns [IfNode node]:
    IF condition=expression terminator
      ifBody=expressions
    (ELSE terminator
      elseBody=expressions
    )?
    END                             { $node = new IfNode($condition.node, $ifBody.nodes, $elseBody.nodes); }
  ;

whileBlock returns [WhileNode node]:
    WHILE condition=expression terminator
      body=expressions
    END                             { $node = new WhileNode($condition.node, $body.nodes); }
  ;

tryBlock returns [TryNode node]:
    TRY terminator
      tryBody=expressions                   { $node = new TryNode($tryBody.nodes); }
    (CATCH CONSTANT COLON NAME terminator
      catchBody=expressions                 { $node.addCatchBlock($CONSTANT.text, $NAME.text, $catchBody.nodes);  }
    )*
    END
  ;

