package yourlang.lang;

/**
  Language runtime. Mostly helper methods for retrieving global values.
*/
public class YourLangRuntime {
  static YourLangClass objectClass;
  static YourLangObject mainObject;
  static YourLangObject nilObject;
  static YourLangObject trueObject;
  static YourLangObject falseObject;
  
  public static YourLangClass getObjectClass() {
    return objectClass;
  }

  public static YourLangObject getMainObject() {
    return mainObject;
  }

  public static YourLangClass getRootClass(String name) {
    // objectClass is null when boostrapping
    return objectClass == null ? null : (YourLangClass) objectClass.getConstant(name);
  }

  public static YourLangClass getExceptionClass() {
    return getRootClass("Exception");
  }
  
  public static YourLangObject getNil() {
    return nilObject;
  }
  
  public static YourLangObject getTrue() {
    return trueObject;
  }

  public static YourLangObject getFalse() {
    return falseObject;
  }
  
  public static YourLangObject toBoolean(boolean value) {
    return value ? YourLangRuntime.getTrue() : YourLangRuntime.getFalse();
  }
}
