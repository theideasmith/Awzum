package yourlang.lang.nodes;

import yourlang.lang.*;

public class WhileNode extends Node {
  private Node condition;
  private Node body;
  
  public WhileNode(Node condition, Node body) {
    this.condition = condition;
    this.body = body;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    while (condition.eval(context).isTrue()) {
      body.eval(context);
    }
    return YourLangRuntime.getNil();
  }
}