package yourlang.lang;

import yourlang.lang.nodes.Node;

/**
  Handle the catching of exception.
*/
public class ExceptionHandler {
  private Evaluable handler;
  private String localName;
  private YourLangClass klass;
  
  /**
    Creates an ExceptionHandler specialized in handling one type of Exception.
    @param klass      Runtime class of the exception handled
    @param localName  Name of the local variable in which the exception will
                      be stored when catched.
    @param handler    Code to eval when the exception is catched.
  */
  public ExceptionHandler(YourLangClass klass, String localName, Evaluable handler) {
    this.localName = localName;
    this.handler = handler;
    this.klass = klass;
  }
  
  /**
    Returns true if this handler can take care of this exception.
  */
  public boolean handle(YourLangException e) {
    return klass.isSubclass(e.getRuntimeClass());
  }
  
  /**
    Called to run a catch block when an exception occured.
  */
  public YourLangObject run(Context context, YourLangException e) throws YourLangException {
    if (localName != null) {
      context.setLocal(localName, e.getRuntimeObject());
    }
    return handler.eval(context);
  }
}