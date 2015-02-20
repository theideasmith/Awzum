# Exception handling

# Any exception raised in the try block, will by catched by the appropriate
# catch block, is present, or else, reraised.
try
  # To raise an exception, call "raise!" on its instance.
  Exception.new("catch this").raise!
  print("This is never executed, NEVER!")
# Store the exception in the variable e
catch Exception : e
  print(e.class.name, e.message)
end
# => Exception
# => catch this

# We can specify several catch blocks.
try
  ouch!
catch MethodNotFound : e
  print(e.class.name, "ok")
catch Exception : e
  print("oop")
end
# => MethodNotFound
# => ok