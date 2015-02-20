package yourlang.lang.nodes;

import java.util.List;

import yourlang.lang.*;

public class ClassDefinitionNode extends Node {
  private String name;
  private String superName;
  private Node body;
  
  public ClassDefinitionNode(String name, String superName, Node body) {
    this.name = name;
    this.superName = superName;
    this.body = body;
  }
  
  public YourLangObject eval(Context context) throws YourLangException {
    YourLangClass klass;
    // Default superclass to Object.
    if (superName == null) {
      klass = new YourLangClass(name);
    } else {
      YourLangClass superClass = (YourLangClass) context.getCurrentClass().getConstant(superName);
      klass = new YourLangClass(name, superClass);
    }
    
    // Evaluated the body of the class with self=class and class=class.
    body.eval(new Context(klass, klass));
    // Add the class as a constant
    context.getCurrentClass().setConstant(name, klass);
    
    return klass;
  }
}