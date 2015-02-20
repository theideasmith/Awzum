package yourlang.lang;

/**
  Exception thrown when a unknown method is called.
*/
public class ArgumentError extends YourLangException {
  public ArgumentError(String method, int expected, int actual) {
    super("Expected " + expected + " arguments for " + method + ", got " + actual);
    setRuntimeClass("ArgumentError");
  }
}