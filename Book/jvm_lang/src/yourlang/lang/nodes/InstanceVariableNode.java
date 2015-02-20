package yourlang.lang.nodes;

import yourlang.lang.*;

public class InstanceVariableNode extends Node {
  private String name;
  
  public InstanceVariableNode(String name) {
    this.name = name;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    return context.getCurrentSelf().getInstanceVariable(name);
  }
}