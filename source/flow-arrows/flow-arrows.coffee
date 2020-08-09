Take ["FlowArrows:Config","FlowArrows:Process","FlowArrows:Set","Reaction","Tick"],
(                 Config ,            Process ,            Set , Reaction , Tick)->
  sets = []
  visible = true # Default to true, in case we don't have an arrows button

  enableAll = ()->
    for set in sets
      set.enabled = visible
    undefined

  Tick (time, dt)->
    if visible
      for set in sets
        if set.parentScope.alpha > 0
          f = dt * Config.SPEED
          s = Config.SCALE
          set.update f, s
    undefined

  Reaction "FlowArrows:Show", ()-> enableAll visible = true
  Reaction "FlowArrows:Hide", ()-> enableAll visible = false

  Make "FlowArrows", Config.wrap (parentScope, lineData...)->
    if not parentScope? then console.log lineData; throw new Error "FlowArrows was called with a null target. ^^^ was the baked line data."

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
