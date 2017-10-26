# The Registry allows us to advertise the existence of global maps and arrays of stuff,
# with explicit control over when things can be registered and when they can be requested.
# If you register something after registration closes, or request something before it closes,
# you get slapped on the wrist.

do ()->
  named = {}
  unnamed = {}
  closed = {}
  
  Make "Registry", Registry =
    add: (type, item)->
      if closed[type] then console.log item; throw new Error "^^^ This #{type} was registered too late."
      (unnamed[type] ?= []).push item
    
    all: (type, byName = false)->
      if not closed[type] then throw new Error "Registry.all(#{type}, #{byName}) was called before registration closed."
      if byName
        named[type]
      else
        unnamed[type]
    
    set: (type, name, item)->
      if closed[type] then console.log item; throw new Error "^^^ This #{type} named \"#{name}\" was registered too late."
      if named[type]?[name]? then console.log item; throw new Error "^^^ This #{type} is using the name \"#{name}\", which is already in use."
      (named[type] ?= {})[name] = item
    
    get: (type, name)->
      if not closed[type] then throw new Error "Registry.get(#{type}, #{name}) was called before registration closed."
      named[type][name]
    
    closeRegistration: (type)->
      closed[type] = true
