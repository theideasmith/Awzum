package yourlang.lang.nodes;

import yourlang.lang.*;

public class InstanceVariableAssignNode extends Node {
  private String name;
  private Node expression;
  
  public InstanceVariableAssignNode(String name, Node expression) {
    this.name = name;
    this.expression = expression;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    YourLangObject value = expression.eval(context);
    context.getCurrentSelf().setInstanceVariable(name, value);
    return value;
  }
}