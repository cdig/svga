Take [], ()->
  Make "Global", global = {}
  internal = {}
  
  readWrite = (name, initial)->
    internal[name] = initial
    Object.defineProperty global, name,
      get: ()->    internal[name]
      set: (val)-> internal[name] = val
  
  #################################################################################################
  
  readWrite "animateMode", false
  
  Object.defineProperty global, "schematicMode",
    get: ()->   !internal.animateMode
    set: (val)-> internal.animateMode = !val
  
  readWrite "enableHydraulicLines"
