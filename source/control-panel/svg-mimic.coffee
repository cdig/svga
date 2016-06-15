Take ["Draggable", "PointerInput", "DOMContentLoaded"], (Draggable, PointerInput)->
  Make "SVGMimic", SVGMimic = (activity, control, controlButton)->
    return scope =
      activity: null
      open: false
      disabled: false
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
        if scope.open then scope.hide() else scope.show()
      
      show: ()->
        return if scope.disabled
        scope.open = true
        control.style.show(true)

      hide: ()->
        scope.open = false
        control.style.show(false)

      disable: ()->
        scope.hide()
        scope.disabled = true
      
      enable: ()->
        scope.disabled = false
