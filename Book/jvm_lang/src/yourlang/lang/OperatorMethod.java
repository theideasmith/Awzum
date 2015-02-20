package yourlang.lang;

/**
  Specialized method of operators (+, -, *, /, etc.)
*/
public abstract class OperatorMethod<T> extends Method {
  @SuppressWarnings("unchecked")
  public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
    T self = (T) receiver.as(ValueObject.class).getValue();
    T arg = (T) arguments[0].as(ValueObject.class).getValue();
    return perform(self, arg);
  }
  
  public abstract YourLangObject perform(T receiver, T argument) throws YourLangException;
}
