Take ["PointerInput", "DOMContentLoaded"], (PointerInput)->
  Make "SVGArrows", SVGArrows = (activity, arrows, controlButton)->
    return scope =
      showing: true

      setup: ()->
        PointerInput.addClick controlButton.getElement(), scope.toggle

      toggle: ()->
        if scope.showing then scope.hide() else scope.show()

      show: ()->
        scope.showing = true
        arrows.show()

      hide: ()->
        scope.showing = false
        arrows.hide()
