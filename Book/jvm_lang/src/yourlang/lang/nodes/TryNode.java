package yourlang.lang.nodes;

import java.util.ArrayList;

import yourlang.lang.*;

/**
  A try-catch block.
*/
public class TryNode extends Node {
  private Node body;
  private ArrayList<CatchBlock> catchBlocks;
  
  public TryNode(Node body) {
    this.body = body;
    catchBlocks = new ArrayList<CatchBlock>();
  }
  
  /**
    Add a block to catch exception of type typeName. Storing the exception in
    localName and evaluating body.
  */
  public void addCatchBlock(String typeName, String localName, Node body) {
    catchBlocks.add(new CatchBlock(typeName, localName, body));
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    Context tryContext = context.makeChildContext();
    
    try {
      return body.eval(tryContext);
    } catch (YourLangException exception) {
      // If there's an exception we run through all exception handler and run
      // the first one that can handle the exception.
      for (CatchBlock block : catchBlocks) {
        ExceptionHandler handler = block.toExceptionHandler();
        if (handler.handle(exception)) return handler.run(tryContext, exception);
      }
      // No catch block for this exception, rethrow. Can be catched from a parent
      // context.
      throw exception;
    }
  }
  
  /**
    One catch block.
  */
  private class CatchBlock {
    private String typeName;
    private String localName;
    private Node body;
    
    public CatchBlock(String typeName, String localName, Node body) {
      this.typeName = typeName;
      this.localName = localName;
      this.body = body;
    }
    
    public ExceptionHandler toExceptionHandler() {
      return new ExceptionHandler(YourLangRuntime.getRootClass(typeName), localName, body);
    }
  }
}