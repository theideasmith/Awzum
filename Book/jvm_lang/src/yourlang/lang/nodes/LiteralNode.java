package yourlang.lang.nodes;

import yourlang.lang.*;

public class LiteralNode extends Node {
  YourLangObject value;
  
  public LiteralNode(YourLangObject value) {
    this.value = value;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    return value;
  }
}