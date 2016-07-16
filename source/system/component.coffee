do ()->
  definitions = {}
  instantiatedStarted = false
  
  Make "Component", Component =
    make: (type, name, args...)->
      if instantiatedStarted then throw "The component \"#{name}\" arrived after setup started. Please figure out a way to make it initialize faster."
      (definitions[type] ?= {})[name] = if args.length is 1 then args[0] else args
    
    take: (type, name)->
      instantiatedStarted = true
      ofType = definitions[type] or {}
      return if name? then ofType[name] else ofType
