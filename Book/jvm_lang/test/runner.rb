require "fileutils"

# Simple test runner that compares output of running a script with the comments beginning
# with '=>' in the file.
class TestRunner
  include FileUtils
  
  def initialize(bin, pattern, dir)
    @bin      = bin
    @total    = 0
    @failures = []
    @pattern  = pattern
    @dir      = dir
  end
  
  def run
    cd @dir do
      Dir[@pattern].each do |file|
        expected = File.read(file).split("\n").map { |l| l[/^# => (.*)$/, 1] }.compact.join("\n")
        actual   = test(file)
        if expected == actual
          pass(file)
        else
          fail(file, expected, actual)
        end
      end
      
      puts
      
      @failures.each do |file, expected, actual|
        puts "[%s]" % file
        puts "    expected #{expected.inspect}"
        puts "         got #{actual.inspect}"
        puts
      end
      
      puts "#{@total} tests, #{@failures.size} failures"
    end
  end
  
  def run_and_exit!
    run
    exit @failures.empty? ? 0 : 1
  end
  
  protected
    def test(*args)
      cmd = "#{@bin} #{args * ' '}"
      `#{cmd}`.chomp
    end

    def pass(file)
      @total += 1
      print "."
    end

    def fail(file, expected, actual)
      @total += 1
      @failures << [file, expected, actual]
      print "F"
    end
end

TestRunner.new("bin/yourlang", "test/*.yl", File.dirname(__FILE__) + "/..").run_and_exit!
