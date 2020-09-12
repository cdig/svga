Take ["FlowArrows:Config","FlowArrows:Containerize","FlowArrows:Segment"],
(                 Config ,            Containerize ,            Segment)->
  Make "FlowArrows:Set", (parentElm, setData)->
    Containerize parentElm, (scope)-> # This function must return an array of children
      for segmentData, i in setData

        if segmentData.dist < Config.FADE_LENGTH * 2
          throw new Error "You have a FlowArrows segment that is only #{Math.round segmentData.dist} units long, which is clashing with your fade length of #{Config.FADE_LENGTH} units. Please don't set MIN_SEGMENT_LENGTH less than FADE_LENGTH * 2."

        childName = "segment" + i
        child = Segment scope.element, segmentData, childName, parentElm.id
        scope[childName] = child
