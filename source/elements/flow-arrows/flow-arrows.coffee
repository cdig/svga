Take ["Organizer", "RequestUniqueAnimation"], (Organizer, RequestUniqueAnimation)->
  Make "FlowArrows", FlowArrows = ()->
    currentTime = null
    elapsedTime = 0
    requested = false
    
    removeOriginalArrow = (selectedSymbol)->
      children = []
      for child in selectedSymbol.childNodes
        children.push child
      for child in children
        selectedSymbol.removeChild(child)

    update = (time)->
      RequestUniqueAnimation(update)
      currentTime = time if not currentTime?
      dT = (time - currentTime)/1000
      currentTime = time
      elapsedTime += dT
      return unless scope.isVisible
      for arrowsContainer in scope.arrowsContainers
        arrowsContainer.update(dT)

    return scope =
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
        
        unless requested
          requested = true
          RequestUniqueAnimation(update)
        
        return arrowsContainer
      
      show: ()->
        scope.isVisible = true
        for arrowsContainer in scope.arrowsContainers
          arrowsContainer.visible(true)
      
      hide: ()->
        scope.isVisible = false
        for arrowsContainer in scope.arrowsContainers
          arrowsContainer.visible(false)
      
      start: ()->
        console.log "FlowArrows.start() is deprecated. Please remove it from your animation."
