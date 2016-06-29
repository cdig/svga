Take ["Organizer", "Reaction", "RequestUniqueAnimation"], (Organizer, Reaction, RequestUniqueAnimation)->
  Make "FlowArrows", FlowArrows = ()->
    currentTime = null
    
    removeOriginalArrow = (selectedSymbol)->
      children = []
      for child in selectedSymbol.childNodes
        children.push child
      for child in children
        selectedSymbol.removeChild(child)
    
    update = (time)->
      RequestUniqueAnimation(update)
      currentTime ?= time
      dT = (time - currentTime)/1000
      currentTime = time
      return unless scope.isVisible
      for arrowsContainer in scope.arrowsContainers
        arrowsContainer.update dT
    
    scope =
      # state
      isVisible: false
      #constants please don't change
      SPEED: 200
      MIN_EDGE_LENGTH: 8
      MIN_SEGMENT_LENGTH: 1
      CONNECTED_DISTANCE: 1
      ARROWS_PROPERTY: "arrows"
      #customizable
      scale: 0.75
      SPACING: 600
      FADE_LENGTH: 50
      arrowsContainers: []
      
      setup: (parent, selectedSymbol, linesData)->
        removeOriginalArrow(selectedSymbol)
        arrowsContainer = new ArrowsContainer(selectedSymbol)
        scope.arrowsContainers.push arrowsContainer
        for lineData in linesData
          Organizer.build(parent,lineData.edges, arrowsContainer, this)
        
        RequestUniqueAnimation update, true
        
        return arrowsContainer
      
      show: ()->
        scope.isVisible = true
        for arrowsContainer in scope.arrowsContainers
          arrowsContainer.visible(true)
      
      hide: ()->
        scope.isVisible = false
        for arrowsContainer in scope.arrowsContainers
          arrowsContainer.visible(false)
      
      animateMode: ()->
        for arrowsContainer in scope.arrowsContainers
          arrowsContainer.visible(scope.isVisible)
      
      schematicMode: ()->
        for arrowsContainer in scope.arrowsContainers
          arrowsContainer.visible(false)
      
      start: ()->
        console.log "FlowArrows.start() is deprecated. Please remove it from your animation."
      
      
    Reaction "Schematic:Show", scope.schematicMode
    Reaction "Schematic:Hide", scope.animateMode

    return scope
