do ()->
  items = {}
  tooLate = false
  
  Make "Registry", Registry =
    add: (type, item, name)->
      if name?
        if tooLate then console.log item; throw "^ Registry.add was called after registration closed. Please make #{type}: #{name} init faster."
        (items[type] ?= {})[name] = item
      else
        if tooLate then console.log item; throw "^ Registry.add was called after registration closed. Please make this #{type} init faster."
        (items[type] ?= []).push item
    
    all: (type)->
      return items[type]
    
    closeRegistration: ()->
      tooLate = true
