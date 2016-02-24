do ->
  Take ["PointerInput", "DOMContentLoaded"], (PointerInput)->
    Make "SVGArrows", SVGArrows = (activity, arrows, controlButton)->
      return scope =
        open: true

        setup: ()->
          PointerInput.addClick controlButton.getElement(), scope.toggle

        toggle: ()->
          scope.open = not scope.open
          if scope.open then scope.show() else scope.hide()

        show: ()->
          scope.open = true
          arrows.show()

        hide: ()->
          scope.open = false
          arrows.hide()