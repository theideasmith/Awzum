package yourlang.lang;

/**
  Exception that can be catched from inside the runtime.
*/
public class YourLangException extends Exception {
  private YourLangClass runtimeClass;
  
  /**
    Creates a new exception from a runtime class.
    @param runtimeClass Class of the exception from whitin the language.
  */
  public YourLangException(YourLangClass runtimeClass, String message) {
    super(message);
    this.runtimeClass = runtimeClass;
  }

  public YourLangException(YourLangClass runtimeClass) {
    super();
    this.runtimeClass = runtimeClass;
  }
  
  public YourLangException(String runtimeClassName, String message) {
    super(message);
    setRuntimeClass(runtimeClassName);
  }
  
  /**
    Creates a new exception from the Exception runtime class.
  */
  public YourLangException(String message) {
    super(message);
    this.runtimeClass = YourLangRuntime.getExceptionClass();
  }
  
  /**
    Wrap an exception to pass it to the runtime.
  */
  public YourLangException(Exception inner) {
    super(inner);
    setRuntimeClass(inner.getClass().getName());
  }
  
  /**
    Returns the runtime instance (the exception inside the language) of this exception.
  */
  public YourLangObject getRuntimeObject() {
    YourLangObject instance = runtimeClass.newInstance(this);
    instance.setInstanceVariable("message", new ValueObject(getMessage()));
    return instance;
  }

  public YourLangClass getRuntimeClass() {
    return runtimeClass;
  }

  protected void setRuntimeClass(String name) {
    runtimeClass = YourLangRuntime.getExceptionClass().subclass(name);
  }
}