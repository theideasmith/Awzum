package yourlang.lang;

import java.util.HashMap;

/**
  Class in the runtime.
  Classes store methods and constants. Each object in the runtime has a class.
*/
public class YourLangClass extends YourLangObject {
  private String name;
  private YourLangClass superClass;
  private HashMap<String, Method> methods;
  HashMap<String, YourLangObject> constants;
  
  /**
    Creates a class inheriting from superClass.
  */
  public YourLangClass(String name, YourLangClass superClass) {
    super("Class");
    this.name = name;
    this.superClass = superClass;
    methods = new HashMap<String, Method>();
    constants = new HashMap<String, YourLangObject>();
  }
  
  /**
    Creates a class inheriting from Object.
  */
  public YourLangClass(String name) {
    this(name, YourLangRuntime.getObjectClass());
  }
  
  public String getName() {
    return name;
  }
  
  public YourLangClass getSuperClass() {
    return superClass;
  }
  
  public void setConstant(String name, YourLangObject value) {
    constants.put(name, value);
  }

  public YourLangObject getConstant(String name) {
    if (constants.containsKey(name)) return constants.get(name);
    if (superClass != null) return superClass.getConstant(name);
    return YourLangRuntime.getNil();
  }
  
  public boolean hasConstant(String name) {
    if (constants.containsKey(name)) return true;
    if (superClass != null) return superClass.hasConstant(name);
    return false;
  }
  
  public Method lookup(String name) throws MethodNotFound {
    if (methods.containsKey(name)) return methods.get(name);
    if (superClass != null) return superClass.lookup(name);
    throw new MethodNotFound(name);
  }

  public boolean hasMethod(String name) {
    if (methods.containsKey(name)) return true;
    if (superClass != null) return superClass.hasMethod(name);
    return false;
  }
  
  public void addMethod(String name, Method method) {
    methods.put(name, method);
  }
  
  /**
    Creates a new instance of the class.
  */
  public YourLangObject newInstance() {
    return new YourLangObject(this);
  }
  
  /**
    Creates a new instance of the class, storing the value inside a ValueObject.
  */
  public YourLangObject newInstance(Object value) {
    return new ValueObject(this, value);
  }
  
  /**
    Creates a new subclass of this class.
  */
  public YourLangClass newSubclass(String name) {
    YourLangClass klass = new YourLangClass(name, this);
    YourLangRuntime.getObjectClass().setConstant(name, klass);
    return klass;
  }
  
  /**
    Creates or returns a subclass if it already exists.
  */
  public YourLangClass subclass(String name) {
    YourLangClass objectClass = YourLangRuntime.getObjectClass();
    if (objectClass.hasConstant(name)) return (YourLangClass) objectClass.getConstant(name);
    return newSubclass(name);
  }
  
  /**
    Returns true if klass is a subclass of this class.
  */
  public boolean isSubclass(YourLangClass klass) {
    if (klass == this) return true;
    if (klass.getSuperClass() == null) return false;
    if (klass.getSuperClass() == this) return true;
    return isSubclass(klass.getSuperClass());
  }
  
  @Override
  public boolean equals(Object other) {
    if (other == this) return true;
    if ( !(other instanceof YourLangClass) ) return false;
    return name == ((YourLangClass)other).getName();
  }
}
