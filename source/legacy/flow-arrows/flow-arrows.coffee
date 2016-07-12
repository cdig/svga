Take ["FlowArrows:Config", "FlowArrows:Set", "Reaction", "Tick"], (Config, Set, Reaction, Tick)->
  animateMode = true # Default to true, in case we don't have a schematic mode
  visible = true # Default to true, in case we don't have an arrows button
  sets = []
  
  FlowArrows =
    setup: (selectedSymbol, lines)->
      # selectedSymbol is the symbol that was selected when BakeLines was executed in Flash
      
      # This removes invisible lines (lines with a child named markerBox)
      if selectedSymbol.querySelector "[id^=markerBox]" # ^= matches values by prefix, so we can match IDs like markerBox_FL
        while selectedSymbol.hasChildNodes()
          selectedSymbol.removeChild selectedSymbol.firstChild
      
      for line in lines
        segmentDatas = Process line.edges
      
      set = Set selectedSymbol, lines
      sets.push set
      set # Composable
    
    show: ()-> updateVisibility visible = true
    hide: ()-> updateVisibility visible = false
    start: ()-> throw "FlowArrows.start() has been removed. Just delete it."
  
  
  for prop in ["SCALE", "SPACING", "FADE_LENGTH", "MIN_SEGMENT_LENGTH", "SPEED", "MIN_EDGE_LENGTH", "CONNECTED_DISTANCE"]
    Object.defineProperty FlowArrows, prop,
      get: ()-> Config[prop]
      set: (v)-> Config[prop] = v
  
  
  updateVisibility = ()->
    for set in sets
      set.visible = visible and animateMode

  
  Tick (dt, time)->
    if visible and animateMode
      for set in sets
        set.update dt
  
  
  Reaction "Schematic:Hide", ()-> updateVisibility animateMode = true
  Reaction "Schematic:Show", ()-> updateVisibility animateMode = false
  Reaction "FlowArrows:Show", FlowArrows.show
  Reaction "FlowArrows:Hide", FlowArrows.hide
  
  Make "FlowArrows", FlowArrows
