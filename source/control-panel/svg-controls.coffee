Take [], ()->
  Make "SVGControls", SVGControls = (svgElement)->
    return scope =
      controls: []
      open: false
      setup: ()->
        svgElement.addEventListener "click", scope.click


      addControl: (control)->
        scope.controls.push control

      click: ()->
        scope.open = not scope.open
        for control in scope.controls
          if scope.open
            control.show()
          else
            control.hide()


