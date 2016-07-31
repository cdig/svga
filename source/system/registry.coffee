do ()->
  named = {}
  unnamed = {}
  tooLate = false
  
  Make "Registry", Registry =
    add: (type, item)->
      if tooLate then console.log item; throw "^ Registry.add was called after registration closed. Please make this #{type} init faster."
      (unnamed[type] ?= []).push item
    
    all: (type)->
      unnamed[type]
    
    set: (type, name, item)->
      if tooLate then console.log item; throw "^ Registry.set was called after registration closed. Please make #{type}: #{name} init faster."
      if named[type]?[name]? then console.log item; throw "^ Registry.add(#{type}, ^^^, #{name}) is a duplicate. Please pick a different name."
      (named[type] ?= {})[name] = item
    
    get: (type, name)->
      named[type]?[name]
    
    closeRegistration: ()->
      tooLate = true
