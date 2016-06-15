Take [], ()->
  Make "SVGControls", SVGControls = (svgElement)->
    return scope =
      controls: []
      disabled: false
      open: false
      
      setup: ()->
        svgElement.addEventListener "click", scope.toggle
      
      addControl: (control)->
        scope.controls.push control
      
      toggle: ()->
        if scope.open then scope.hide() else scope.show()
      
      show: ()->
        return if scope.disabled
        scope.open = true
        control.show() for control in scope.controls
      
      hide: ()->
        scope.open = false
        control.hide() for control in scope.controls

      disable: ()->
        scope.hide()
        scope.disabled = true
      
      enable: ()->
        scope.disabled = false
