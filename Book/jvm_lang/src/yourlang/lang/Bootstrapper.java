package yourlang.lang;

import java.io.*;

/**
  Bootstrapper.run() is called to initialize the runtime.
  Core classes are created and methods are added.
*/
public class Bootstrapper {
  static public Context run() {
    // Create core classes
    YourLangClass objectClass = new YourLangClass("Object");
    YourLangRuntime.objectClass = objectClass;
    // Each method sent or added on the root context of a script are evaled on the main object.
    YourLangObject main = new YourLangObject();
    YourLangRuntime.mainObject = main;
    YourLangClass classClass = new YourLangClass("Class");
    objectClass.setYourLangClass(classClass); // Object is a class
    classClass.setYourLangClass(classClass); // Class is a class
    main.setYourLangClass(objectClass);
    
    // Register core classes into the root context
    objectClass.setConstant("Object", objectClass);
    objectClass.setConstant("Class", classClass);
    // There is just one instance of nil, true, false, so we store those in constants.
    YourLangRuntime.nilObject = objectClass.newSubclass("NilClass").newInstance(null);
    YourLangRuntime.trueObject = objectClass.newSubclass("TrueClass").newInstance(true);
    YourLangRuntime.falseObject = objectClass.newSubclass("FalseClass").newInstance(false);
    YourLangClass stringClass = objectClass.newSubclass("String");
    YourLangClass numberClass = objectClass.newSubclass("Number");
    YourLangClass integerClass = numberClass.newSubclass("Integer");
    YourLangClass floatClass = numberClass.newSubclass("Float");
    YourLangClass exceptionClass = objectClass.newSubclass("Exception");
    exceptionClass.newSubclass("IOException");
    exceptionClass.newSubclass("TypeError");
    exceptionClass.newSubclass("MethodNotFound");
    exceptionClass.newSubclass("ArgumentError");
    exceptionClass.newSubclass("FileNotFound");
    
    // Add methods to core classes.
    
    //// Object
    objectClass.addMethod("print", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        for (YourLangObject arg : arguments) System.out.println(arg.toJavaObject());
        return YourLangRuntime.getNil();
      }
    });
    objectClass.addMethod("class", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        return receiver.getYourLangClass();
      }
    });
    objectClass.addMethod("eval", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        Context context = new Context(receiver);
        String code = arguments[0].asString();
        return context.eval(code);
      }
    });
    objectClass.addMethod("require", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        Context context = new Context();
        String filename = arguments[0].asString();
        try {
          return context.eval(new FileReader(filename));
        } catch (FileNotFoundException e) {
          throw new YourLangException("FileNotFound", "File not found: " + filename);
        }
      }
    });
    
    //// Class
    classClass.addMethod("new", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        YourLangClass self = (YourLangClass) receiver;
        YourLangObject instance = self.newInstance();
        if (self.hasMethod("initialize")) instance.call("initialize", arguments);
        return instance;
      }
    });
    classClass.addMethod("name", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        YourLangClass self = (YourLangClass) receiver;
        return new ValueObject(self.getName());
      }
    });
    classClass.addMethod("superclass", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        YourLangClass self = (YourLangClass) receiver;
        return self.getSuperClass();
      }
    });

    //// Exception
    exceptionClass.addMethod("initialize", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        if (arguments.length == 1) receiver.setInstanceVariable("message", arguments[0]);
        return YourLangRuntime.getNil();
      }
    });
    exceptionClass.addMethod("message", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        return receiver.getInstanceVariable("message");
      }
    });
    objectClass.addMethod("raise!", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        String message = null;
        if (receiver.hasInstanceVariable("message")) message = receiver.getInstanceVariable("message").asString();
        throw new YourLangException(receiver.getYourLangClass(), message);
      }
    });
    
    //// Integer
    integerClass.addMethod("+", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return new ValueObject(receiver + argument);
      }
    });
    integerClass.addMethod("-", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return new ValueObject(receiver + argument);
      }
    });
    integerClass.addMethod("*", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return new ValueObject(receiver * argument);
      }
    });
    integerClass.addMethod("/", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return new ValueObject(receiver / argument);
      }
    });
    integerClass.addMethod("<", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return YourLangRuntime.toBoolean(receiver < argument);
      }
    });
    integerClass.addMethod(">", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return YourLangRuntime.toBoolean(receiver > argument);
      }
    });
    integerClass.addMethod("<=", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return YourLangRuntime.toBoolean(receiver <= argument);
      }
    });
    integerClass.addMethod(">=", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return YourLangRuntime.toBoolean(receiver >= argument);
      }
    });
    integerClass.addMethod("==", new OperatorMethod<Integer>() {
      public YourLangObject perform(Integer receiver, Integer argument) throws YourLangException {
        return YourLangRuntime.toBoolean(receiver == argument);
      }
    });
    
    //// String
    stringClass.addMethod("+", new OperatorMethod<String>() {
      public YourLangObject perform(String receiver, String argument) throws YourLangException {
        return new ValueObject(receiver + argument);
      }
    });
    stringClass.addMethod("size", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        String self = receiver.asString();
        return new ValueObject(self.length());
      }
    });
    stringClass.addMethod("substring", new Method() {
      public YourLangObject call(YourLangObject receiver, YourLangObject arguments[]) throws YourLangException {
        String self = receiver.asString();
        if (arguments.length == 0) throw new ArgumentError("substring", 1, 0);
        int start = arguments[0].asInteger();
        int end = self.length();
        if (arguments.length > 1) end = arguments[1].asInteger();
        return new ValueObject(self.substring(start, end));
      }
    });
    
    // Return the root context on which everything will be evaled. By default, everything is evaled on the
    // main object.
    return new Context(main);
  }
}