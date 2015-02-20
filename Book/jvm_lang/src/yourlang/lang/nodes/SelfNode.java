package yourlang.lang.nodes;

import yourlang.lang.*;

public class SelfNode extends Node {
  public YourLangObject eval(Context context) throws YourLangException {
    return context.getCurrentSelf();
  }
}