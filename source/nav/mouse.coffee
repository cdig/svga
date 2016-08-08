Take ["Config", "Nav"], (Config, Nav)->
  return unless Config.nav

  lastX = 0
  lastY = 0
  down = false

  window.addEventListener "mousedown", (e)->
    e.preventDefault() # Without this, shift-drag pans the ENTIRE SVG! What the hell?
    down = true
    lastX = e.clientX
    lastY = e.clientY

  window.addEventListener "mousemove", (e)->
    # Windows fires this event every tick when touch-dragging, even when the input doesn't move
    if down and (e.clientX isnt lastX or e.clientY isnt lastY) and Nav.eventInside(e)
      Nav.by
        x: e.clientX - lastX
        y: e.clientY - lastY
      lastX = e.clientX
      lastY = e.clientY

  window.addEventListener "mouseup", (e)->
    down = false

  window.addEventListener "dblclick", (e)->
    if Nav.eventInside e
      e.preventDefault()
      Nav.to x:0, y:0, z:0

  window.addEventListener "wheel", (e)->
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
