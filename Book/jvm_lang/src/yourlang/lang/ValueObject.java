package yourlang.lang;

/**
  Object storing a Java value, usualy a literal (String, Integer, Float, nil,
  true, false).
*/
public class ValueObject extends YourLangObject {
  private Object value;
  
  public ValueObject(YourLangClass klass, Object value) {
    super(klass);
    this.value = value;
  }

  public ValueObject(String value) {
    super("String");
    this.value = value;
  }

  public ValueObject(Integer value) {
    super("Integer");
    this.value = value;
  }

  public ValueObject(Float value) {
    super("Float");
    this.value = value;
  }

  public ValueObject(Object value) {
    super("Object");
    this.value = value;
  }
  
  /**
    Returns the Java value of this object.
  */
  @Override
  public Object toJavaObject() {
    return value;
  }
  
  /**
    Only nil and false are false.
  */
  @Override
  public boolean isFalse() {
    return value == (Object)false || isNil();
  }
  
  /**
    Only nil is nil.
  */
  @Override
  public boolean isNil() {
    return value == null;
  }
  
  public Object getValue() {
    return value;
  }
  
  /**
    Cast the value to clazz or throw a TypeError if unexpected type.
  */
  public <T> T getValueAs(Class<T> clazz) throws TypeError {
    if (clazz.isInstance(value)){
      return clazz.cast(value);
    }
    throw new TypeError(clazz.getName(), value);
  }
}
