package yourlang.lang.nodes;

import yourlang.lang.*;

public class IfNode extends Node {
  private Node condition;
  private Node ifBody;
  private Node elseBody;
  
  public IfNode(Node condition, Node ifBody, Node elseBody) {
    this.condition = condition;
    this.ifBody = ifBody;
    this.elseBody = elseBody;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    if (condition.eval(context).isTrue()) {
      return ifBody.eval(context);
    } else if (elseBody != null) {
      return elseBody.eval(context);
    }
    return YourLangRuntime.getNil();
  }
}