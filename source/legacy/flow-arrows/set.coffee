Take ["FlowArrows:Process", "FlowArrows:Segment", "SVG"], (Process, Segment, SVG)->
  Make "FlowArrows:Set", (FlowArrows, selectedSymbol, lines)->
    
    segments = []
    direction = 1
    flow = 1
    pressure = 0
    visible = true
    showing = true
    
    set =
      scale: 1
      target: target = SVG.create "g", parent

      reverse: ()->
        direction *= -1
      
      update: (dt)->
        if showing
          for segment in segments
            segment.update dt, flow * direction

    
    for line in lines
      for segmentData in ArrowsSegmentOrganizer FlowArrows, line.edges
        segment = Segment FlowArrows, set, segmentData, i, segmentLength
        segments.push segment
        set[segment.name] = segment
    
    
    updateShowing = ()->
      showing = visible and flow isnt 0
      SVG.styles target, display: if showing then null else "none"
    
    
    Object.defineProperty set, 'flow',
      get: ()-> flow
      set: (val)->
        if flow isnt val
          flow = val
          updateShowing()
    
    Object.defineProperty set, 'pressure',
      get: ()-> pressure
      set: (val)->
        if pressure isnt val
          pressure = val
          color = Pressure val
          SVG.attrs target, fill: color, stroke: color
    
    Object.defineProperty set, 'visible',
      get: ()-> visible
      set: (val)->
        if visible isnt val
          visible = val
          updateShowing()
    
    
    return set
