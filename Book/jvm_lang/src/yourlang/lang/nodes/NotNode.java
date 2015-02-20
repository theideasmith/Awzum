package yourlang.lang.nodes;

import yourlang.lang.*;

/**
  Negate a value.
*/
public class NotNode extends Node {
  private Node receiver;
  
  /**
    !receiver
  */
  public NotNode(Node receiver) {
    this.receiver = receiver;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    if (receiver.eval(context).isTrue())
      return YourLangRuntime.getFalse();
    return YourLangRuntime.getTrue();
  }
}