package yourlang.lang.nodes;

import yourlang.lang.*;

public class AndNode extends Node {
  private Node receiver;
  private Node argument;
  
  /**
    receiver && argument
  */
  public AndNode(Node receiver, Node argument) {
    this.receiver = receiver;
    this.argument = argument;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    YourLangObject receiverEvaled = receiver.eval(context);
    if (receiverEvaled.isTrue())
      return argument.eval(context);
    return receiverEvaled;
  }
}