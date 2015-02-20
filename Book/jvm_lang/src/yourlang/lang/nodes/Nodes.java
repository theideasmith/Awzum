package yourlang.lang.nodes;

import yourlang.lang.*;
import java.util.ArrayList;

/**
  Collection of nodes.
*/
public class Nodes extends Node {
  private ArrayList<Node> nodes;
  
  public Nodes() {
    nodes = new ArrayList<Node>();
  }
  
  public void add(Node n) {
    nodes.add(n);
  }
  
  /**
    Eval all the nodes and return the last returned value.
  */
  public YourLangObject eval(Context context) throws YourLangException {
    YourLangObject lastEval = YourLangRuntime.getNil();
    for (Node n : nodes) {
      lastEval = n.eval(context);
    }
    return lastEval;
  }
}