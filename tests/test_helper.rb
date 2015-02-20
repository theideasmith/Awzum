#I didn't write this testing suite helper. 
#I've never done real unit testing in ruby and as it is 1am right now am too tired to write my own unit testing class
$:.unshift File.expand_path("../../", __FILE__)
require "test/unit"
require "stringio"

class Test::Unit::TestCase
  def capture_streams
    out = StringIO.new
    $stdout = out
    $stderr = out
    yield
    out.rewind
    out.read
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end
  
  def assert_prints(expected, &block)
    assert_equal expected, capture_streams(&block)
  end
end