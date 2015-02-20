require "rubygems"
require "parser"
require "nodes"

require "llvm/core"
require "llvm/execution_engine"
require "llvm/transforms/scalar"

LLVM.init_x86

class LLVMCompiler
  # First we initialize some data types we'll use during compilation.
  # Both correspond to common C types.
  PCHAR = LLVM.Pointer(LLVM::Int8) # equivalent to *char in C
  INT   = LLVM::Int # equivalent to int in C
  
  # When storing a value in a local variable, LLVM will return back a pointer.
  # We need to keep track of the mapping local variable name => pointer.
  # This is what the following Hash does.
  attr_reader :locals
  
  # An instance of `LLVMCompiler` is responsible for compiling a given function.
  # We pass an LLVM module (`mod`), which is a container in which to store the code,
  # and a function to compile the code into.
  #
  # By default the function will be the standard C entry point: `void main()`.
  def initialize(mod=nil, function=nil)
    @module = mod || LLVM::Module.new("awesome")
    
    @locals = {} # To track local names during compilation
    
    @function = function ||
                @module.functions.named("main") || # Default the function to `main`
                @module.functions.add("main", [], LLVM.Void)
    
    @builder = LLVM::Builder.new # Prepare a builder to build code.
    @builder.position_at_end(@function.basic_blocks.append)
    
    @engine = LLVM::JITCompiler.new(@module) # The machine code compiler.
  end
  
  # Before compiling our code, we'll declare external C functions we'll call from within
  # our program. Here is where our compiler will cheat quite a bit. Instead of reimplementing
  # our runtime inside the LLVM module, we won't support any of the OOP features and only allow
  # calling basic C functions we declare here, namely `int puts(char*)`.
  def preamble
    fun = @module.functions.add("puts", [PCHAR], INT)
    fun.linkage = :external
  end
  
  # Always finish the function with a `return`.
  def finish
    @builder.ret_void
  end
  
  # We'll also need to load literal values and be able to call functions. LLVM got us covered there.
  def new_string(value)
    @builder.global_string_pointer(value)
  end

  def new_number(value)
    LLVM::Int(value)
  end
  
  def call(name, args=[])
    function = @module.functions.named(name)
    @builder.call(function, *args)
  end
  
  # Keep in mind we're compiling to machine code that will run right inside the processor.
  # There is no extra layer of abstraction here. When assigning local variables, we
  # first need to allocate memory for it. This is what we do here using `alloca` and then
  # store the value at that address in memory.
  def assign(name, value)
    ptr = @builder.alloca(value.type) # Allocate memory.
    @builder.store(value, ptr) # Store the value in the allocated memory.
    @locals[name] = ptr # Keep track of where we stored the local.
  end
  
  def load(name)
    ptr = @locals[name]
    @builder.load(ptr, name) # Load back the value stored for that local.
  end
  
  # Methods defined inside our runtime are compiled to functions (like C functions).
  # Functions are compiled using their own `LLVMCompiler` instance to scope their
  # local variables and code blocks.
  def function(name)
    func = @module.functions.add(name, [], LLVM.Void)
    compiler = LLVMCompiler.new(@module, func)
    yield compiler
    compiler.finish
  end
  
  # One of the biggest advantage of using LLVM and not rolling our owning machine code
  # compiler is that we're able to take advantage of all the optimizations. Compiling
  # to machine code is the "easy" (super giant quotes here) part. But by default your
  # code will not be that fast, you need to optimize it. This is what the `-O2`
  # option of your C compiler does. Here we'll only use one optimization as an example,
  # but LLVM has a lot of them.
  def optimize
    @module.verify! # Verify the code is valid.
    pass_manager = LLVM::PassManager.new(@engine)
    pass_manager.mem2reg! # Promote memory to machine registers.
  end
  
  # Here is where the magic happens! We JIT compile and run the LLVM code. JIT, for
  # just-in-time, because we compile it right before we execute it as opposed to AOT,
  # for ahead-of-time where we compile it upfront, like C.
  def run
    @engine.run_function(@function)
  end
  
  # LLVM doesn't compile directly to machine code but to an intermediate format called IR,
  # which is similar to assembly. If you want to inspect the generated IR for this module,
  # call the following method.
  def dump
    @module.dump
  end
end

# Now that we have our compiler ready we use the same approach as before and
# reopen all the supported nodes and implement how each one is compiled.
class Nodes
  def llvm_compile(compiler)
    nodes.map { |node| node.llvm_compile(compiler) }.last
  end
end

class NumberNode
  def llvm_compile(compiler)
    compiler.new_number(value)
  end
end

class StringNode
  def llvm_compile(compiler)
    compiler.new_string(value)
  end
end

# To keep things simple, our compiler only supports a subset of our Awesome
# language. For example, we only support calling methods on `self` and not
# on given receivers. We also don't support method parameters when defining methods.
# This is why we raise an error in the following nodes.
# See at the end of this chapter for more details on what is not supported and where
# to go from here.
class CallNode
  def llvm_compile(compiler)
    raise "Receiver not supported for compilation" if receiver
    
    compiled_arguments = arguments.map { |arg| arg.llvm_compile(compiler) }
    compiler.call(method, compiled_arguments)
  end
end

class GetLocalNode
  def llvm_compile(compiler)
    compiler.load(name)
  end
end

class SetLocalNode
  def llvm_compile(compiler)
    compiler.assign(name, value.llvm_compile(compiler))
  end
end

class DefNode
  def llvm_compile(compiler)
    raise "Parameters not supported for compilation" if !params.empty?
    compiler.function(name) do |function|
      body.llvm_compile(function)
    end
  end
end
