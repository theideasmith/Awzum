package yourlang.lang;

import java.util.HashMap;
import java.util.ArrayList;

import java.io.Reader;
import java.io.StringReader;
import java.io.IOException;

import org.antlr.runtime.ANTLRReaderStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;

import yourlang.lang.nodes.Node;


/**
  Evaluation context. Determines how a node will be evaluated.
  A context tracks local variables, self, and the current class under which
  methods and constants will be added.
  
  There are three different types of context:
  1) In the root of the script, self = main object, class = Object
  2) Inside a method body, self = instance of the class, class = method class
  3) Inside a class definition self = the class, class = the class
*/
public class Context {
  private YourLangObject currentSelf;
  private YourLangClass currentClass;
  private HashMap<String, YourLangObject> locals;
  // A context can share local variables with a parent. For example, in the
  // try block.
  private Context parent;
  
  public Context(YourLangObject currentSelf, YourLangClass currentClass, Context parent) {
    this.currentSelf = currentSelf;
    this.currentClass = currentClass;
    this.parent = parent;
    if (parent == null) {
      locals = new HashMap<String, YourLangObject>();
    } else {
      locals = parent.locals;
    }
  }
  
  public Context(YourLangObject currentSelf, YourLangClass currentClass) {
    this(currentSelf, currentClass, null);
  }
  
  public Context(YourLangObject currentSelf) {
    this(currentSelf, currentSelf.getYourLangClass());
  }
  
  public Context() {
    this(YourLangRuntime.getMainObject());
  }
  
  public YourLangObject getCurrentSelf() {
    return currentSelf;
  }

  public YourLangClass getCurrentClass() {
    return currentClass;
  }
  
  public YourLangObject getLocal(String name) {
    return locals.get(name);
  }
    
  public boolean hasLocal(String name) {
    return locals.containsKey(name);
  }
    
  public void setLocal(String name, YourLangObject value) {
    locals.put(name, value);
  }
  
  /**
    Creates a context that will share the same attributes (locals, self, class)
    as the current one.
  */
  public Context makeChildContext() {
    return new Context(currentSelf, currentClass, this);
  }
  
  /**
    Parse and evaluate the content red from the reader (eg.: FileReader, StringReader).
  */
  public YourLangObject eval(Reader reader) throws YourLangException {
    try {
      YourLangLexer lexer = new YourLangLexer(new ANTLRReaderStream(reader));
      YourLangParser parser = new YourLangParser(new CommonTokenStream(lexer));
      Node node = parser.parse();
      if (node == null) return YourLangRuntime.getNil();
      return node.eval(this);
    } catch (YourLangException e) {
      throw e;
    } catch (Exception e) {
      throw new YourLangException(e);
    }
  }
  
  public YourLangObject eval(String code) throws YourLangException {
    return eval(new StringReader(code));
  }
}
