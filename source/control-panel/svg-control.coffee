do -> 
  Take ["PointerInput","PureDom","SVGTransform", "Vector", "DOMContentLoaded"], (PointerInput, PureDom, SVGTransform, Vector)->

    vecFromEventGlobal = (e)->
      return Vector.add(Vector.create(e.clientX, e.clientY), Vector.fromPageOffset())
    
    getParentRect = (element)->
      parent = PureDom.querySelectorParent(element, "svg")
      rect = parent.getBoundingClientRect()
      width = rect.width
      height = rect.height

      return rect

    mouseConversion = (position, svgActivity, width, height)->
      xDiff = width / svgActivity.getBoundingClientRect().width 
      yDiff = height / svgActivity.getBoundingClientRect().height 
      x = position.x * xDiff
      y = position.y * yDiff
      return {x: x, y: y}

    convertToPercentage = (element, position)->
      parent = getParentRect(element)
      x = 100 * position.x / parent.width
      y = 100 * position.y / parent.height
      return {x: x, y: y}




    updateMousePos = (e, mouse)->
      mouse.pos = vecFromEventGlobal(e)
      mouse.delta = Vector.subtract(mouse.pos, mouse.last)
      mouse.last = mouse.pos

    Make "SVGControl", SVGControl = (control, controlButton)->
      return scope = 
        mouse: null
        dragging: false
        transform: null
        activity: null
        open: false

        setup: (svgActivity)->

          scope.activity = svgActivity

          properties = svgActivity.getElement().getAttribute("viewBox").split(" ")
          scope.viewWidth = parseFloat(properties[2])
          scope.viewHeight = parseFloat(properties[3])

          scope.mouse = {}
          scope.mouse.pos = {x: 0, y:0}
          scope.mouse.delta = {x: 0, y:0}
          scope.mouse.last = {x: 0, y:0}

          PointerInput.addDown control.getElement(), scope.mouseDown
          PointerInput.addMove control.getElement(), scope.mouseMove
          PointerInput.addMove svgActivity.getElement(), scope.mouseMove
          PointerInput.addUp control.getElement(), scope.mouseUp
          PointerInput.addUp svgActivity.getElement(), scope.mouseUp
          controlButton.getElement().addEventListener "click", scope.toggle
          if control.closer?
            control.closer.getElement().addEventListener "click", scope.hide if control.closer
          else
            console.log "Error: Control does not have closer button"

          scope.hide()
        toggle: ()->
          scope.open = not scope.open
          if scope.open then scope.show() else scope.hide()

        show: ()->
          scope.open = true
          control.style.show(true)

        hide: ()->
          scope.open = false
          control.style.show(false)
        mouseDown: (e)->
          updateMousePos(e, scope.mouse)
          if e.button is 0
            scope.dragging = true


        mouseMove: (e)->
          updateMousePos(e, scope.mouse)
          if scope.dragging
            svgActivity = document.querySelector("svg-activity")
            newMouse = mouseConversion(scope.mouse.delta,scope.activity.getElement(), scope.viewWidth, scope.viewHeight )
            control.transform.x += newMouse.x
            control.transform.y += newMouse.y


        mouseUp: (e)->
          scope.dragging = false



