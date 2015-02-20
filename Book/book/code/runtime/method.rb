class AwesomeMethod
  def initialize(params, body)
    @params = params
    @body = body
  end
  
  def call(receiver, arguments)
    # Create a context of evaluation in which the method will execute.
    context = Context.new(receiver)
    
    # Assign passed arguments to local variables.
    @params.each_with_index do |param, index|
      context.locals[param] = arguments[index]
    end
    
    # The body is a node (created in the parser).
    # We'll talk in details about the `eval` method in the interpreter chapter.
    @body.eval(context)
  end
end
