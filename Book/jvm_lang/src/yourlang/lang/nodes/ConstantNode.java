package yourlang.lang.nodes;

import yourlang.lang.*;

/**
  Get the value of a constant.
*/
public class ConstantNode extends Node {
  private String name;
  
  public ConstantNode(String name) {
    this.name = name;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    return context.getCurrentClass().getConstant(name);
  }
}