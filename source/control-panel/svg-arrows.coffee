Take ["PointerInput", "Global", "DOMContentLoaded"], (PointerInput, Global)->
  Make "SVGArrows", SVGArrows = (activity, arrows, controlButton)->
    return scope =
      showing: true
      disabled: false
      
      setup: ()->
        PointerInput.addClick controlButton.getElement(), scope.toggle
        scope.show()
        
      toggle: ()->
        if scope.showing then scope.hide() else scope.show()
      
      show: ()->
        return if scope.disabled
        scope.showing = true
        arrows.show()
        Global.flowArrows = true # TEMPORARY HACK
      
      hide: ()->
        return if scope.disabled
        scope.showing = false
        arrows.hide()
        Global.flowArrows = false # TEMPORARY HACK
      
      disable: ()->
        scope.disabled = true
        arrows.hide()
      
      enable: ()->
        scope.disabled = false
        arrows.show() if scope.showing
