do ->
  Take ["Ease", "PointerInput"], (Ease, PointerInput)->
    setupElementWithFunction = (svgElement, element, behaviourCode, behaviour)->
      behaviourId = 0
      PointerInput.addDown element, ()->
        behaviourId = setInterval behaviour, 16
      PointerInput.addUp element, ()->
        clearInterval behaviourId
      PointerInput.addUp svgElement, ()->
        clearInterval behaviourId

      keyBehaviourId = 0
      keyDown = false
      svgElement.addEventListener "keydown", (e)->
        if keyDown
          return
        if e.keyCode is behaviourCode
          keyDown = true
          keyBehaviourId = setInterval behaviour, 16

      svgElement.addEventListener "keyup", (e)->
        if e.keyCode is behaviourCode
          clearInterval keyBehaviourId
          keyDown = false

    Make "SVGCamera", SVGCamera = (svgElement, mainStage, navOverlay, control)->
      return scope =
        baseX: 0
        baseY: 0
        centerX: 0
        maxZoom: 8.0
        minZoom: 0.75
        centerY: 0
        transX: 0
        transY: 0
        baseWidth: 0
        baseHeight: 0
        zoom: 1
        open: false
        mainStage: null
        transValue : 10
        navOverlay: null


        setup: ()->
          scope.mainStage = mainStage
          navOverlay.style.show(false)

          control.getElement().addEventListener "click", scope.toggle

          navOverlay.reset.getElement().addEventListener "click", ()->
            scope.zoomToPosition(1, 0, 0)

          navOverlay.close.getElement().addEventListener "click", scope.toggle

          setupElementWithFunction svgElement, navOverlay.up.getElement(), 38, scope.up

          setupElementWithFunction svgElement, navOverlay.down.getElement(), 40, scope.down

          setupElementWithFunction svgElement, navOverlay.left.getElement(), 37, scope.left


          setupElementWithFunction svgElement, navOverlay.right.getElement(), 39, scope.right


          setupElementWithFunction svgElement, navOverlay.plus.getElement(),187, scope.zoomIn


          setupElementWithFunction svgElement, navOverlay.minus.getElement(), 189, scope.zoomOut

          svgElement.addEventListener "keydown", (e)-> #this gives an output for positions to later put into POI
            if e.keyCode is 88
              console.log "Positions are x: #{scope.transX}, y: #{scope.transY}, zoom: #{scope.zoom}"
        toggle: ()->
          scope.open = !scope.open
          if scope.open
            navOverlay.style.show(true)
          else
            navOverlay.style.show(false)
        left: ()->
          scope.transX += scope.transValue * 1.0 / scope.zoom
          stop = svgElement.getBoundingClientRect().width / 2
          scope.transX = stop if scope.transX > stop

          scope.mainStage.transform.x = scope.transX

        right: ()->
          scope.transX -= scope.transValue * 1.0 / scope.zoom
          stop = -svgElement.getBoundingClientRect().width / 2
          scope.transX = stop if scope.transX < stop

          scope.mainStage.transform.x = scope.transX


        up: ()->
          scope.transY += scope.transValue * 1.0 / scope.zoom
          stop = svgElement.getBoundingClientRect().height / 2
          scope.transY = stop if scope.transY > stop
          scope.mainStage.transform.y = scope.transY


        down: ()->
          scope.transY -= scope.transValue * 1.0 / scope.zoom
          stop = -svgElement.getBoundingClientRect().height / 2
          scope.transY = stop if scope.transY < stop
          scope.mainStage.transform.y = scope.transY

        zoomIn: ()->
          scope.zoom += scope.getZoomIncrease()

          if scope.zoom > scope.maxZoom
            scope.zoom = scope.maxZoom

          scope.mainStage.transform.scale = scope.zoom

        zoomOut: ()->
          scope.zoom -= scope.getZoomIncrease()
          if scope.zoom < scope.minZoom
            scope.zoom = scope.minZoom
          scope.mainStage.transform.scale = scope.zoom

        transform: (x, y, scale)->
          scope.zoom = scale
          scope.mainStage.transform.scale = scope.zoom
          scope.transX = x
          scope.mainStage.transform.x = scope.transX
          scope.transY = y
          scope.mainStage.transform.y = scope.transY

        smoothTransformProperty: (property, start, end)->
          timeToTransform = 1
          currentTime = null
          totalTime = 0
          transformProperty = (time)->
            currentTime = time if not currentTime?
            totalTime += (time - currentTime) / 1000
            currentTime = time

            newValue = Ease.cubic(totalTime, 0, timeToTransform, start, end)
            scope[property] = newValue
            scope.setViewBox()

            if totalTime < timeToTransform
              requestAnimationFrame(transformProperty)
          requestAnimationFrame(transformProperty)


        getZoomIncrease: ()->
          zoomSpeed = 0.03
          zoomIncrease = zoomSpeed * scope.zoom
          return zoomIncrease
        setViewBox : ()->
          if scope.zoom < scope.maxZoom
            scope.zoom = scope.maxZoom
          if scope.zoom > scope.minZoom
            scope.zoom = scope.minZoom
          ntX = scope.transX * scope.zoom
          ntY = scope.transY * scope.zoom
          ncX = (scope.centerX + scope.transX) - (scope.centerX + scope.transX) * scope.zoom
          ncY = (scope.centerY + scope.transY) - (scope.centerY + scope.transY) * scope.zoom
          svgElement.setAttribute("viewBox", "#{ncX + ntX} #{ncY + ntY} #{scope.baseWidth * scope.zoom} #{scope.baseHeight * scope.zoom}")

        zoomToPosition: (newZoom, newX, newY)->
          currentTime = null
          increaseScale = 2
          increaseTransform = 80
          timeElapsed = 0
          xDiff = Math.abs(scope.transX - newX)
          yDiff = Math.abs(scope.transY - newY)
          scaleDiff = Math.abs(scope.zoom - newZoom)
          xDone = false
          yDone = false
          zoomDone = false
          easeFunction = Ease.quartic
          animateToPosition = (time)->
            if currentTime is null
              currentTime = time
            delta = (time - currentTime) / 1000
            currentTime = time
            timeElapsed += delta
            scope.mainStage.transform.x = easeFunction(timeElapsed * increaseTransform, 0, xDiff, scope.transX, newX)
            if timeElapsed * increaseTransform >= xDiff
              xDone = true
              scope.transX = newX
              scope.mainStage.transform.x = scope.transX
            scope.mainStage.transform.y = easeFunction(timeElapsed * increaseTransform, 0, yDiff, scope.transY, newY)
            if timeElapsed * increaseTransform >= yDiff
              yDone = true
              scope.transY = newY
              scope.mainStage.transform.y = scope.transY

            scope.mainStage.transform.scale = easeFunction(timeElapsed * increaseScale, 0, scaleDiff, scope.zoom, newZoom)
            if timeElapsed * increaseScale > scaleDiff
              zoomDone = true
              scope.zoom = newZoom
              scope.mainStage.transform.scale = scope.zoom

            if not (xDone and yDone and zoomDone)
              requestAnimationFrame animateToPosition

          requestAnimationFrame animateToPosition




