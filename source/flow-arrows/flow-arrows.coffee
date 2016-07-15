Take ["FlowArrows:Config","FlowArrows:Process","FlowArrows:Set","Reaction","Tick"],
(                 Config ,            Process ,            Set , Reaction , Tick)->
  sets = []
  visible = true # Default to true, in case we don't have an arrows button
  animateMode = true # Default to true, in case we don't have a schematic mode
  
  enableAll = ()->
    for set in sets
      set.enabled = visible and animateMode
  
  Tick (time, dt)->
    if visible and animateMode
      for set in sets
        if set.parentScope.visible
          f = dt * Config.SPEED
          s = Config.SCALE
          set.update f, s
  
  Reaction "Schematic:Hide", ()-> setTimeout ()-> enableAll animateMode = true # Wait one extra tick, to give the creator's symbol code a chance to init all the appropriate flow/pressure values before we appear
  Reaction "Schematic:Show", ()-> enableAll animateMode = false
  Reaction "FlowArrows:Show", ()-> enableAll visible = true
  Reaction "FlowArrows:Hide", ()-> enableAll visible = false
  
  Make "FlowArrows", Config.wrap (parentScope, lineData...)->
    elm = parentScope.element
    
    # This removes invisible lines (which have a child named markerBox)
    if elm.querySelector "[id^=markerBox]" # ^= matches values by prefix, so we can match IDs like markerBox_FL
      while elm.hasChildNodes()
        elm.removeChild elm.firstChild
    
    setData = Process lineData
    set = Set elm, setData
    set.parentScope = parentScope
    sets.push set
    set
    
