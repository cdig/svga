Take ["Draggable", "PointerInput", "DOMContentLoaded"], (Draggable, PointerInput)->
  Make "SVGControl", SVGControl = (activity, control, controlButton)->
    return scope =
      activity: null
      open: false
      draggable: null

      setup: ()->
        scope.draggable = new Draggable(control, activity)
        scope.draggable.setup()
        PointerInput.addClick controlButton.getElement(), scope.toggle
        if control.closer?
          PointerInput.addClick control.closer.getElement(), scope.hide
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