package yourlang.lang;

import java.util.HashMap;

/**
  Any object, instance of a class, inside the runtime.
  Objects store a class and instance variables.
*/
public class YourLangObject {
  private YourLangClass yourLangClass;
  private HashMap<String, YourLangObject> instanceVariables;
  
  /**
    Creates an instance of class yourLangClass.
  */
  public YourLangObject(YourLangClass yourLangClass) {
    this.yourLangClass = yourLangClass;
    this.instanceVariables = new HashMap<String, YourLangObject>();
  }
  
  public YourLangObject(String className) {
    this(YourLangRuntime.getRootClass(className));
  }
  
  public YourLangObject() {
    this(YourLangRuntime.getObjectClass());
  }
  
  public YourLangClass getYourLangClass() {
    return yourLangClass;
  }
  
  public void setYourLangClass(YourLangClass klass) {
    yourLangClass = klass;
  }
  
  public YourLangObject getInstanceVariable(String name) {
    if (hasInstanceVariable(name))
      return instanceVariables.get(name);
    return YourLangRuntime.getNil();
  }

  public boolean hasInstanceVariable(String name) {
    return instanceVariables.containsKey(name);
  }
  
  public void setInstanceVariable(String name, YourLangObject value) {
    instanceVariables.put(name, value);
  }
  
  /**
    Call a method on the object.
  */
  public YourLangObject call(String method, YourLangObject arguments[]) throws YourLangException {
    return yourLangClass.lookup(method).call(this, arguments);
  }

  public YourLangObject call(String method) throws YourLangException {
    return call(method, new YourLangObject[0]);
  }
  
  /**
    Only false and nil are not true.
  */
  public boolean isTrue() {
    return !isFalse();
  }
  
  /**
    Only false and nil are false. This is overridden in ValueObject.
  */
  public boolean isFalse() {
    return false;
  }

  /**
    Only nil is nil. This is overridden in ValueObject.
  */
  public boolean isNil() {
    return false;
  }
  
  /**
    Convert to a Java object. This is overridden in ValueObject.
  */
  public Object toJavaObject() {
    return this;
  }
  
  public <T> T as(Class<T> clazz) throws TypeError {
    if (clazz.isInstance(this)){
      return clazz.cast(this);
    }
    throw new TypeError(clazz.getName(), this);
  }
  
  public String asString() throws TypeError {
    return as(ValueObject.class).getValueAs(String.class);
  }

  public Integer asInteger() throws TypeError {
    return as(ValueObject.class).getValueAs(Integer.class);
  }

  public Float asFloat() throws TypeError {
    return as(ValueObject.class).getValueAs(Float.class);
  }
}
