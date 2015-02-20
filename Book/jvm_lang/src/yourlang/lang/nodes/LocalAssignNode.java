package yourlang.lang.nodes;

import yourlang.lang.*;

public class LocalAssignNode extends Node {
  private String name;
  private Node expression;
  
  public LocalAssignNode(String name, Node expression) {
    this.name = name;
    this.expression = expression;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    YourLangObject value = expression.eval(context);
    context.setLocal(name, value);
    return value;
  }
}