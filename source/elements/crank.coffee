Take ["Ease", "Vector", "PointerInput"], (Ease, Vector, PointerInput)->
  Make "crank", Crank = (svgElement)->
    return scope =
      deadbands: []
      unmapped: 0
      domainMin: 0
      domainMax: 359
      rangeMin: -1
      rangeMax: 1
      oldAngle: 0
      newAngle: 0
      progress: 0
      rotation: 0
      callback: ()->

      setup: ()->
        PointerInput.addDown svgElement, scope.mouseDown

      setCallback: (callBackFunction)->
        scope.callback = callBackFunction

      getValue: ()->
        return Ease.linear(scope.transform.angle, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax)

      setValue: (input)->
        scope.unmapped = Ease.linear(input, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax)

      setDomain: (min, max)->
        scope.domainMin = min
        scope.domainMax = max
        if scope.transform.angle < scope.domainMin
          scope.transform.angle = scope.rotation = scope.unmapped = scope.domainMin
        else if scope.transform.angle > scope.domainMax
          scope.transform.angle = scope.rotation = scope.unmapped = scope.domainMax
    
      setRange: (min, max)->
        scope.rangeMin = min
        scope.rangeMax = max
      
      addDeadband: (min, set, max)->
        deadband = {min: min, set: set, max: max}
        scope.deadbands.push deadband
        return deadband

#     // UPDATE /////////////////////////////////////////////////////////
      begin: (e)->
        clientRect = svgElement.getBoundingClientRect()
        scope.position = Vector.fromRectPos(clientRect)
        scope.position.x += clientRect.width / 2
        scope.position.y += clientRect.height / 2

        mousePos = Vector.fromEventClient(e)

        scope.oldAngle = Math.atan2(mousePos.y - scope.position.y, mousePos.x - scope.position.x)

        
      compute: (e)->
        mousePos = Vector.fromEventClient(e)
        scope.newAngle = Math.atan2(mousePos.y - scope.position.y, mousePos.x - scope.position.x)
        
        progress = scope.newAngle - scope.oldAngle
        if progress > Math.PI
          progress += -2 * Math.PI
        else
          if progress < -Math.PI then progress += 2 * Math.PI else progress += 0
        scope.unmapped += progress * 180/Math.PI
        scope.update()

      update: ()->
        scope.unmapped = Math.max(scope.domainMin, Math.min(scope.domainMax, scope.unmapped))
        rotation = scope.unmapped
        for band in scope.deadbands
          if rotation > band.min and rotation < band.max
            rotation = band.set
        scope.transform.angle = rotation
        scope.oldAngle = scope.newAngle
        if callback?
          callback()

      mouseDown: (e)->

        PointerInput.addMove scope.root.getElement(), scope.mouseMove
        PointerInput.addUp scope.root.getElement(), scope.mouseUp
        PointerInput.addUp window, scope.mouseUp

        scope.begin(e)
        scope.compute(e)

      
      mouseMove: (e)->
        scope.compute(e)

      mouseUp: (e)->
        PointerInput.removeMove scope.root.getElement(), scope.mouseMove
        PointerInput.removeUp scope.root.getElement(), scope.mouseUp
        PointerInput.removeUp window, scope.mouseUp
