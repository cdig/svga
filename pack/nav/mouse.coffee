Take ["Config", "Input", "Nav"], (Config, Input, Nav)->
  return unless Config.nav
  
  dragging = false
  
  calls =
    downOther: (e)->
      e.preventDefault() # Without this, shift-drag pans the ENTIRE SVG! What the hell?
      if Nav.eventInside e
        dragging = true
    
    dragOther: (e, state)->
      if dragging and state.down
        Nav.by
          x: state.deltaX
          y: state.deltaY
    
    upOther: ()->
      dragging = false
  
  window.addEventListener "dblclick", (e)->
    return unless e.button is 0
    if Nav.eventInside e
      e.preventDefault()
      Nav.to x:0, y:0, z:0
  
  window.addEventListener "wheel", (e)->
    return unless e.button is 0
    if Nav.eventInside e
      e.preventDefault()

      # Is this a pixel-precise input device (eg: magic trackpad)?
      if e.deltaMode is WheelEvent.DOM_DELTA_PIXEL
        if e.ctrlKey # Chrome, pinch to zoom
          Nav.by z: -e.deltaY / 100
        else if e.metaKey # Other browsers, meta+scroll to zoom
          Nav.by z: -e.deltaY / 200
        else
          Nav.by
            x: -e.deltaX
            y: -e.deltaY
            z: -e.deltaZ
      
      # This is probably a scroll wheel
      else
        Nav.by z: -e.deltaY / 200
  
  Input document, calls, true, false
