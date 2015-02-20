module Mio
  # Bootstrap
  object = Object.new
  
  object.def "clone" do |receiver, context|
    receiver.clone
  end
  object.def "set_slot" do |receiver, context, name, value|
    receiver[name.call(context).value] = value.call(context)
  end
  object.def "print" do |receiver, context|
    puts receiver.value
    Lobby["nil"]
  end

  # Introducing the Lobby! Where all the fantastic objects live and also the root
  # context of evaluation.
  Lobby = object.clone

  Lobby["Lobby"]   = Lobby
  Lobby["Object"]  = object
  Lobby["nil"]     = object.clone(nil)
  Lobby["true"]    = object.clone(true)
  Lobby["false"]   = object.clone(false)
  Lobby["Number"]  = object.clone(0)
  Lobby["String"]  = object.clone("")
  Lobby["List"]    = object.clone([])
  Lobby["Message"] = object.clone
  Lobby["Method"]  = object.clone

  # The method we'll use to define methods.
  Lobby.def "method" do |receiver, context, message|
    Method.new(context, message)
  end
end
