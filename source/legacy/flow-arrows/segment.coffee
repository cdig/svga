Take ["FlowArrows:Arrow", "FlowArrows:Config"], (Arrow, Config)->
  Make "FlowArrows:Segment", (set, segmentData, i)->
    
    if segmentData.length < Config.FADE_LENGTH * 2 then throw "You have a segment that is only #{Math.round segmentData.length} units long, which is clashing with your fade length of #{Config.FADE_LENGTH} units. Please don't set MIN_SEGMENT_LENGTH less than FlowArrows.FADE_LENGTH * 2."
    
    direction = 1
    arrows = []
    
    segment =
      flow: 1
      name: "segment" + i
      scale: 1
      visible: true
      
      # Used by Arrows
      edges: segmentData.edges
      length: segmentData.length
      set: set
      
      
      updateVisibility: ()->
        showing = segment.visible and segment.flow isnt 0
        SVG.styles target, display: if showing then null else "none"
        return showing
      
      reverse: ()->
        direction *= -1
      
      
      update: (dt, setFlow)->
        
        ancestorScale = segment.scale * segment.set.scale * Config.SCALE
        if Config.SPACING < 60 * ancestorScale then throw "Your flow arrows are overlapping. What the devil are you trying? You need to convince Ivan that what you are doing is okay before this error will go away. Until then, please make your arrow scale smaller, or your FlowArrows.SPACING bigger."
        if ancestorScale < 0.1 then throw "FlowArrows.SCALE is set to #{Config.SCALE}, which is so small that arrows might not be visible. If this is necessary, then you are doing something suspicious and need to convince Ivan that what you are doing is okay. Until then, this is a fatal error, so please make your FlowArrows.SCALE = 0.1 or larger."
        
        velocity = dt * direction * segment.flow * setFlow * Config.SPEED
        arrow.update velocity for arrow in arrows if velocity isnt 0
    
    
    arrowCount = Math.max 1, Math.round segment.length / Config.SPACING
    segmentSpacing = segment.length / arrowCount
    segmentPosition = 0
    edgePosition = 0
    edgeIndex = 0
    edge = segment.edges[edgeIndex]
    
    for i in [0...arrowCount]
      while (edgePosition > edge.length)
        edgePosition -= edge.length
        edge = segment.edges[++edgeIndex]
      arrow = Arrow set.target, segment, segmentPosition, edgePosition, edgeIndex
      arrows.push arrow
      edgePosition += segmentSpacing
      segmentPosition += segmentSpacing
    
    
    return segment
