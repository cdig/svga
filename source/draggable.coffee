Take ["PointerInput","PureDom","SVGTransform", "Vector", "DOMContentLoaded"], (PointerInput, PureDom, SVGTransform, Vector)->
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

  Make "Draggable", Draggable = (instance, parent=null)->
    return scope =
      mouse: null
      dragging: false
      setup: ()->
        if parent?
          properties = parent.getElement().getAttribute("viewBox").split(" ")
          scope.viewWidth = parseFloat(properties[2])
          scope.viewHeight = parseFloat(properties[3])
        scope.mouse = {}
        scope.mouse.pos = {x: 0, y:0}
        scope.mouse.delta = {x: 0, y:0}
        scope.mouse.last = {x: 0, y:0}
        PointerInput.addDown instance.grabber.getElement(), scope.mouseDown
        PointerInput.addMove instance.getElement(), scope.mouseMove
        PointerInput.addMove parent.getElement(), scope.mouseMove if parent?
        PointerInput.addUp instance.getElement(), scope.mouseUp
        PointerInput.addUp parent.getElement(), scope.mouseUp if parent?

      mouseDown: (e)->
        updateMousePos(e, scope.mouse)
        if e.button is 0
          scope.dragging = true


      mouseMove: (e)->
        updateMousePos(e, scope.mouse)
        if scope.dragging
          if parent?
            newMouse = mouseConversion(instance, scope.mouse.delta,parent.getElement(), scope.viewWidth, scope.viewHeight )
          else
            newMouse = {x: scope.mouse.x, y: scope.mouse.y}

          instance.transform.x += newMouse.x
          instance.transform.y += newMouse.y


      mouseUp: (e)->
        scope.dragging = false
