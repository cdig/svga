do ()->
  Make "Global", Global = {}
  internal = {}
  
  readWrite = (name, initial)->
    internal[name] = initial
    Object.defineProperty Global, name,
      get: ()->    internal[name]
      set: (val)-> internal[name] = val
  
  #################################################################################################
  
  readWrite "animateMode", false
  
  Object.defineProperty Global, "schematicMode",
    get: ()->   !internal.animateMode
    set: (val)-> internal.animateMode = !val
  
  readWrite "legacyHydraulicLines", false
