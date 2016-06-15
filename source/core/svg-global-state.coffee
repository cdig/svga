Take [], ()->
  global = {}
  Make "SVGGlobalState", ()-> global
  
  Object.defineProperty global, "animateMode",
    get: ()-> global.animateMode
    set: (val)-> global.animateMode = val
  
  Object.defineProperty global, "schematicMode",
    get: ()-> !global.animateMode
    set: (val)-> global.animateMode = !val
