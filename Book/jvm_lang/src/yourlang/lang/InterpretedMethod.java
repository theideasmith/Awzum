package yourlang.lang;

import yourlang.lang.nodes.Node;

/**
  Method defined inside a script.
*/
public class InterpretedMethod extends Method {
  private String name;
  private Evaluable body;
  private String parameters[];
  
  /**
    Creates a new method.
    @param name       Name of the method.
    @param parameters Name of the method parameters.
    @param body       Object to eval when the method is called (usually a Node).
  */
  public InterpretedMethod(String name, String parameters[], Evaluable body) {
    this.name = name;
    this.parameters = parameters;
    this.body = body;
  }
  
  /**
    Calls the method and evaluate the body.
  */
  public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
    // Evaluates the method body in the contect of the receiver
    Context context = new Context(receiver);

    if (parameters.length != arguments.length)
      throw new ArgumentError(name, parameters.length, arguments.length);
    
    // Puts arguments in locals
    for (int i = 0; i < parameters.length; i++) {
      context.setLocal(parameters[i], arguments[i]);
    }

    return body.eval(context);
  }
}
