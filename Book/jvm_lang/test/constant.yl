# Constants start with a capital letter.
X = 1

print(X)
# => 1

class ConstantTest
  Y = 2

  def get_y
    # Constants are stored at class-level and shared by all instances.
    Y
  end
  
  def get_x
    # Constants are looked up in parent classes.
    X
  end
end

constant_test = ConstantTest.new

print(constant_test.get_x)
# => 1

print(constant_test.get_y)
# => 2