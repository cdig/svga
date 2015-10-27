do->
  Take "Organizer", (Organizer)->
    removeOriginalArrow = (selectedSymbol)->
      children = []
      for child in selectedSymbol.childNodes
        children.push child 
      for child in children
        selectedSymbol.removeChild(child)

    startAnimation = (arrowsContainers)->
      currentTime = null
      elapsedTime = 0
      update = (time)->
        currentTime = time if not currentTime?
        dT = (time - currentTime)/1000
        currentTime = time
        elapsedTime += dT 
        for arrowsContainer in arrowsContainers
          arrowsContainer.update(dT)
        requestAnimationFrame(update)
      requestAnimationFrame(update)

    Make "FlowArrows", FlowArrows = ()->
      return scope =    
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

          return arrowsContainer

        show: ()->
          for arrowsContainer in scope.arrowsContainers
            arrowsContainer.visible = true

        hide: ()->
          for arrowsContainer in scope.arrowsContainers
            arrowsContainer.visible = false

        start: ()->
          startAnimation(scope.arrowsContainers)