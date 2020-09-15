Take ["FlowArrows:Arrow","FlowArrows:Config","FlowArrows:Containerize","Mode"],
(                 Arrow ,            Config ,            Containerize , Mode)->
  Make "FlowArrows:Segment", (parentElm, segmentData, segmentName, topElm)->
    Containerize parentElm, (scope)-> # This function must return an array of children
      if Mode.dev
        scope.element.addEventListener "mouseover", ()->

          ids = []
          currentElm = topElm
          while currentElm?
            ids.push currentElm.id if currentElm.id?
            break if currentElm.id is "root"
            currentElm = currentElm.parentElement
          
          console.log "#{segmentName} in the arrows for @#{ids.join '.'}"

      arrowCount = Math.max 1, Math.round segmentData.dist / Config.SPACING
      segmentSpacing = segmentData.dist / arrowCount
      segmentPosition = 0
      vectorPosition = 0
      vectorIndex = 0
      vector = segmentData.vectors[vectorIndex]
      for i in [0...arrowCount]
        while (vectorPosition > vector.dist)
          vectorPosition -= vector.dist
          vector = segmentData.vectors[++vectorIndex]
        arrow = Arrow scope.element, segmentData, segmentPosition, vectorPosition, vectorIndex
        vectorPosition += segmentSpacing
        segmentPosition += segmentSpacing
        arrow
