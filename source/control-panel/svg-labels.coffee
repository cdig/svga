do ->
  Take ["PointerInput", "DOMContentLoaded"], (PointerInput)->
    Make "SVGLabels", SVGLabels = (activity, labels, controlButton)->
      return scope =
        open: true

        setup: ()->
          PointerInput.addClick controlButton.getElement(), scope.toggle

        toggle: ()->
          scope.open = not scope.open
          if scope.open then scope.show() else scope.hide()

        show: ()->
          scope.open = true
          labels.style.show(true)

        hide: ()->
          scope.open = false
          labels.style.show(false)