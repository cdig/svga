do ->
  Take ["Ease", "PointerInput"], (Ease, PointerInput)->
    setupElementWithFunction = (svgElement, element, behaviourCode, addBehaviour, releaseBehaviour)->
      behaviourId = 0
      PointerInput.addDown element, ()->
        behaviourId = setInterval addBehaviour, 16
      PointerInput.addUp element, ()->
        releaseBehaviour()
        clearInterval behaviourId
      PointerInput.addUp svgElement, ()->
        releaseBehaviour()
        clearInterval behaviourId

      keyBehaviourId = 0
      keyDown = false
      svgElement.addEventListener "keydown", (e)->
        if keyDown
          return
        if e.keyCode is behaviourCode
          keyDown = true
          keyBehaviourId = setInterval addBehaviour, 16

      svgElement.addEventListener "keyup", (e)->
        if e.keyCode is behaviourCode
          releaseBehaviour()
          clearInterval keyBehaviourId
          keyDown = false

    Make "SVGCamera", SVGCamera = (svgElement, mainStage, navOverlay, control)->
      return scope =
        baseX: 0
        baseY: 0
        centerX: 0
        maxZoom: 8.0
        minZoom: 0.75
        acceleration: 0.025
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
        velocity: null


        setup: ()->
          scope.velocity = {x:0, y: 0}
          scope.mainStage = mainStage
          scope.handleScaling()
          navOverlay.style.show(false)

          control.getElement().addEventListener "click", scope.toggle

          navOverlay.reset.getElement().addEventListener "click", ()->
            scope.zoomToPosition(1, 0, 0)

          navOverlay.close.getElement().addEventListener "click", scope.toggle

          setupElementWithFunction svgElement, navOverlay.up.getElement(), 38, scope.up, scope.releaseY

          setupElementWithFunction svgElement, navOverlay.down.getElement(), 40, scope.down, scope.releaseY

          setupElementWithFunction svgElement, navOverlay.left.getElement(), 37, scope.left, scope.releaseX


          setupElementWithFunction svgElement, navOverlay.right.getElement(), 39, scope.right, scope.releaseX


          setupElementWithFunction svgElement, navOverlay.plus.getElement(),187, scope.zoomIn, ()->


          setupElementWithFunction svgElement, navOverlay.minus.getElement(), 189, scope.zoomOut, ()->

          svgElement.addEventListener "keydown", (e)-> #this gives an output for positions to later put into POI
            if e.keyCode is 88
              console.log "setTransformation(#{scope.transX}, #{scope.transY}, #{scope.zoom})"
        toggle: ()->
          scope.open = !scope.open
          if scope.open
            navOverlay.style.show(true)
          else
            navOverlay.style.show(false)
        left: ()->
          scope.velocity.x += scope.acceleration if Math.abs(scope.velocity.x) < 1.0
          scope.updateX()

        right: ()->
          scope.velocity.x -= scope.acceleration if Math.abs(scope.velocity.x) < 1.0
          scope.updateX()


        up: ()->
          scope.velocity.y += scope.acceleration if Math.abs(scope.velocity.y) < 1.0
          scope.updateY()


        down: ()->
          scope.velocity.y -= scope.acceleration if Math.abs(scope.velocity.y) < 1.0
          scope.updateY()

        updateX: ()->

          rightStop = svgElement.getBoundingClientRect().width / 2
          leftStop = -svgElement.getBoundingClientRect().width / 2
          length = Math.sqrt(scope.velocity.x * scope.velocity.x + scope.velocity.y * scope.velocity.y)
          length = 1 if scope.velocity.x is 0 and scope.velocity.y is 0
          vX = scope.velocity.x
          vX /= length if length > 1
          scope.transX += (vX * scope.transValue) / scope.zoom
          scope.transX = leftStop if scope.transX < leftStop
          scope.transX = rightStop if scope.transX > rightStop
          scope.mainStage.transform.x = scope.transX

        updateY: ()->
          upStop = svgElement.getBoundingClientRect().height / 2
          downStop = -svgElement.getBoundingClientRect().height / 2
          length = Math.sqrt(scope.velocity.x * scope.velocity.x + scope.velocity.y * scope.velocity.y)
          length = 1 if scope.velocity.x is 0 and scope.velocity.y is 0
          vY = scope.velocity.y
          vY /= length if length > 1
          scope.transY += (vY * scope.transValue) / scope.zoom
          scope.transY = downStop if scope.transY < downStop
          scope.transY = upStop if scope.transY > upStop
          scope.mainStage.transform.y = scope.transY

        releaseX: ()->
          reduceVelocity = (time)->
            if scope.velocity.x < 0
              scope.velocity.x += scope.acceleration
              scope.updateX()
              if scope.velocity.x < 0
                requestAnimationFrame(reduceVelocity)
            else if scope.velocity.x > 0
              scope.velocity.x -= scope.acceleration
              scope.updateX()
              if scope.velocity.x > 0
                requestAnimationFrame(reduceVelocity)
          requestAnimationFrame(reduceVelocity)
        releaseY: ()->
          reduceVelocity = (time)->
            if scope.velocity.y < 0
              scope.velocity.y += scope.acceleration
              scope.updateY()
              if scope.velocity.y < 0
                requestAnimationFrame(reduceVelocity)
            else if scope.velocity.y > 0
              scope.velocity.y -= scope.acceleration
              scope.updateY()
              if scope.velocity.y > 0
                requestAnimationFrame(reduceVelocity)
          requestAnimationFrame(reduceVelocity)


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

        handleScaling: ()->
          navOverlay.transform.y -= 100
          onResize = ()->
            navBox = navOverlay.getElement().getBoundingClientRect()
            navScaleX = window.innerWidth / 2 / navBox.width
            navScaleY = window.innerHeight / 2 / navBox.height
            navScale = Math.min(navScaleX, navScaleY)
            navOverlay.transform.scale *= navScale
          onResize()
          window.addEventListener "resize", onResize


