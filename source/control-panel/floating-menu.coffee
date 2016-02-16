do ->
  Take ["PointerInput","PureDom", "Vector", "DOMContentLoaded"], (PointerInput,PureDom, Vector)->
    vecFromEventGlobal = (e)->
      return Vector.add(Vector.create(e.clientX, e.clientY), Vector.fromPageOffset())

    getParentRect = (element)->
      parent = PureDom.querySelectorParent(element, "svg-activity")
      rect = parent.getBoundingClientRect()
      width = rect.width
      height = rect.height
      return rect
    styleValToNumWithPrecision = (n, p)->
      return parseFloat(n).toFixed(p).replace(/\0+$/, "").replace(/\.$/, "")

    getElementPositionPercentage = (element)->
      parent = getParentRect(element)
      style = element.style# window.getComputedStyle(element)
      if style.left is ""
        style = window.getComputedStyle(element)
      left = 100 * styleValToNumWithPrecision(style.left, 2)/parent.width
      top = 100 * styleValToNumWithPrecision(style.top, 2)/parent.height
      return {x:  parseFloat(styleValToNumWithPrecision(style.left, 2)), y: parseFloat(styleValToNumWithPrecision(style.top, 2))}

    convertToPercentage = (element, position)->
      parent = getParentRect(element)
      x = 100 * position.x / parent.width
      y = 100 * position.y / parent.height
      return {x: x, y: y}

    addMousePercentage = (element, mouse)->
      original = getElementPositionPercentage(element)
      mouseChange = convertToPercentage(element, mouse.delta)
      return {x: original.x + mouseChange.x, y: original.y + mouseChange.y}

    updateMousePos = (e, mouse)->
      mouse.pos = vecFromEventGlobal(e)
      mouse.delta = Vector.subtract(mouse.pos, mouse.last)
      mouse.last = mouse.pos

    Make "FloatingMenu", FloatingMenu = (element)->
      return scope =
        mouse: null
        dragging: false
        setup: (svgActivity)->
          posPercent = getElementPositionPercentage(element)

          scope.mouse = {}
          scope.mouse.pos = {x: 0, y:0}
          scope.mouse.delta = {x: 0, y:0}
          scope.mouse.last = {x: 0, y:0}
          PointerInput.addDown element, scope.mouseDown
          PointerInput.addMove element, scope.mouseMove
          PointerInput.addMove svgActivity, scope.mouseMove
          PointerInput.addUp element, scope.mouseUp


        mouseDown: (e)->
          updateMousePos(e, scope.mouse)
          if e.button is 0
            scope.dragging = true


        mouseMove: (e)->
          updateMousePos(e, scope.mouse)
          if scope.dragging
            newPosition = addMousePercentage(element, scope.mouse)
            element.style.left = "#{newPosition.x}%"
            element.style.top = "#{newPosition.y}%"



        mouseUp: (e)->
          scope.dragging = false



