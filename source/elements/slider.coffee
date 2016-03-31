Take ["Ease", "PointerInput","PureDom","SVGTransform", "Vector", "DOMContentLoaded"], (Ease, PointerInput, PureDom, SVGTransform, Vector)->
  vecFromEventGlobal = (e)->
    return Vector.add(Vector.create(e.clientX, e.clientY), Vector.fromPageOffset())

  getParentRect = (element)->
    parent = PureDom.querySelectorParent(element, "svg")
    rect = parent.getBoundingClientRect()
    width = rect.width
    height = rect.height

    return rect

  mouseConversion = (instance, position, parentElement, width, height)->
    parentRect = getParentRect(parentElement)

    xDiff = width / parentElement.getBoundingClientRect().width / instance.transform.scale
    yDiff = height / parentElement.getBoundingClientRect().height / instance.transform.scale
    diff = Math.max(xDiff, yDiff)
    x = position.x * diff
    y = position.y * diff
    return {x: x, y: y}

  updateMousePos = (e, mouse)->
    mouse.pos = vecFromEventGlobal(e)
    mouse.delta = Vector.subtract(mouse.pos, mouse.last)
    mouse.last = mouse.pos

  Make "slider", Slider = (svgElement)->
    return scope =
      mouse: null
      horizontalSlider: true
      domainMin: 0
      domainMax: 359
      transformX: 0
      transformY: 0
      rangeMin: -1
      rangeMax: 1
      progress: 0
      dragging: false
      callback: ()->

      setup: ()->
        scope.mouse = {}
        #scope.setVertical()
        scope.mouse.pos = {x: 0, y:0}
        scope.mouse.delta = {x: 0, y:0}
        scope.mouse.last = {x: 0, y:0}
        properties = scope.root.getElement().getAttribute("viewBox").split(" ")
        scope.viewWidth = parseFloat(properties[2])
        scope.viewHeight = parseFloat(properties[3])
        PointerInput.addDown svgElement, scope.mouseDown
      setVertical: ()->
        scope.horizontalSlider = false
      setHorizontal: ()->
        scope.horizontalSlider = true
      setCallback: (callBackFunction)->
        scope.callback = callBackFunction

      getValue: ()->
        return Ease.linear(scope.transform.angle, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax)

      setValue: (input)->
        scope.unmapped = Ease.linear(input, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax)

      setDomain: (min, max)->
        scope.domainMin = min
        scope.domainMax = max

      setRange: (min, max)->
        scope.rangeMin = min
        scope.rangeMax = max



      update: ()->
        if callback?
          callback()

      mouseDown: (e)->
        PointerInput.addMove scope.root.getElement(), scope.mouseMove
        PointerInput.addUp scope.root.getElement(), scope.mouseUp
        PointerInput.addUp window, scope.mouseUp
        scope.dragging = true
        updateMousePos(e, scope.mouse)


      mouseMove: (e)->
        updateMousePos(e, scope.mouse)
        if scope.dragging
          if parent?
            newMouse = mouseConversion(scope, scope.mouse.delta,scope.root.getElement(), scope.viewWidth, scope.viewHeight )
          else
            newMouse = {x: scope.mouse.pos.x, y: scope.mouse.y}
          callbackValue = 0
          if scope.horizontalSlider
            scope.transformX += newMouse.x
            scope.transform.x = scope.transformX
            scope.transform.x = scope.domainMin if scope.transform.x < scope.domainMin
            scope.transform.x = scope.domainMax if scope.transform.x > scope.domainMax
            callbackValue = Ease.linear(scope.transform.x, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax)
          else
            scope.transformY += newMouse.y
            scope.transform.y = scope.transformY
            scope.transform.y = scope.domainMin if scope.transform.y < scope.domainMin
            scope.transform.y = scope.domainMax if scope.transform.y > scope.domainMax
            callbackValue = Ease.linear(scope.transform.y, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax)
          scope.callback callbackValue
          #instance.transform.y += newMouse.y

      mouseUp: (e)->
        scope.dragging = true
        PointerInput.removeMove scope.root.getElement(), scope.mouseMove
        PointerInput.removeUp scope.root.getElement(), scope.mouseUp
        PointerInput.removeUp window, scope.mouseUp
