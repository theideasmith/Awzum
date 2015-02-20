package yourlang.lang.nodes;

import yourlang.lang.*;

public class ConstantAssignNode extends Node {
  private String name;
  private Node expression;
  
  public ConstantAssignNode(String name, Node expression) {
    this.name = name;
    this.expression = expression;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    YourLangObject value = expression.eval(context);
    context.getCurrentClass().setConstant(name, value);
    return value;
  }
}