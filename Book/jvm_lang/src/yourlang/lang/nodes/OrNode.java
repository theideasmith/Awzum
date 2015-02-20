package yourlang.lang.nodes;

import yourlang.lang.*;

public class OrNode extends Node {
  private Node receiver;
  private Node argument;
  
  /**
    receiver || argument
  */
  public OrNode(Node receiver, Node argument) {
    this.receiver = receiver;
    this.argument = argument;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    YourLangObject receiverEvaled = receiver.eval(context);
    if (receiverEvaled.isTrue())
      return receiverEvaled;
    return argument.eval(context);
  }
}