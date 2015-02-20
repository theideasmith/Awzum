package yourlang.lang;

import yourlang.lang.nodes.Node;

/**
  Anything that can be evaluated inside a context must implement this interface.
*/
public interface Evaluable {
  YourLangObject eval(Context context) throws YourLangException;
}
