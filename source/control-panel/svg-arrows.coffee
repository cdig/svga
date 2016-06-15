Take ["PointerInput", "DOMContentLoaded"], (PointerInput)->
  Make "SVGArrows", SVGArrows = (activity, arrows, controlButton)->
    return scope =
      showing: true
      disabled: false
      
      setup: ()->
        PointerInput.addClick controlButton.getElement(), scope.toggle
      
      toggle: ()->
        if scope.showing then scope.hide() else scope.show()
      
      show: ()->
        return if scope.disabled
        scope.showing = true
        arrows.show()

      hide: ()->
        scope.showing = false
        arrows.hide()
      
      disable: ()->
        scope.hide()
        scope.disabled = true
      
      enable: ()->
        scope.disabled = false
