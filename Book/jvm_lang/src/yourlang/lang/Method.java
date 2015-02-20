package yourlang.lang;

/**
  A method attached to a YourLangClass.
*/
public abstract class Method {
  /**
    Calls the method.
    @param receiver  Instance on which to call the method (self).
    @param arguments Arguments passed to the method.
  */
  public abstract YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException;
}
