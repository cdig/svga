Take [], ()->
  Make "Global", global = {}

  internal =
    animateMode: false
  
  Object.defineProperty global, "animateMode",
    get: ()->    internal.animateMode
    set: (val)-> internal.animateMode = val
  
  Object.defineProperty global, "schematicMode",
    get: ()->   !internal.animateMode
    set: (val)-> internal.animateMode = !val
