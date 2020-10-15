Take ["Mode", "Nav", "TouchAcceleration"], (Mode, Nav, TouchAcceleration)->
  return unless Mode.nav

  lastTouches = null
  dragging = false


  touchStart = (e)->
    dragging = false
    TouchAcceleration.move x: 0, y: 0 # Stop any momentum scrolling
    if Nav.eventInside e
      e.preventDefault()
      cloneTouches e

  touchMove = (e)->
    if Nav.eventInside e
      e.preventDefault()
      if e.touches.length isnt lastTouches.length
        # noop
      else if e.touches.length > 1
        a = distTouches lastTouches
        b = distTouches e.touches
        Nav.by z: (b - a) / 200
      else
        dragging = true
        TouchAcceleration.move
          x: e.touches[0].clientX - lastTouches[0].clientX
          y: e.touches[0].clientY - lastTouches[0].clientY
      cloneTouches e

  touchEnd = (e)->
    if dragging
      dragging = false
      TouchAcceleration.up()


  # We are safe to use passive: false, because we only do nav when standalone
  window.addEventListener "touchstart", touchStart, passive: false
  window.addEventListener "touchmove", touchMove, passive: false
  window.addEventListener "touchend", touchEnd


  cloneTouches = (e)->
    lastTouches = for t in e.touches
      clientX: t.clientX
      clientY: t.clientY
    undefined

  distTouches = (touches)->
    a = touches[0]
    b = touches[1]
    dx = a.clientX - b.clientX
    dy = a.clientY - b.clientY
    Math.sqrt dx*dx + dy*dy
