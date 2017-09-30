Take ["Mode", "Nav"], (Mode, Nav)->
  return unless Mode.nav
  
  lastTouches = null

  window.addEventListener "touchstart", touchStart = (e)->
    if Nav.eventInside e
      e.preventDefault()
      cloneTouches e
  
  
  window.addEventListener "touchmove", touchMove = (e)->
    if Nav.eventInside e
      e.preventDefault()
      if e.touches.length isnt lastTouches.length
        # noop
      else if e.touches.length > 1
        a = distTouches lastTouches
        b = distTouches e.touches
        Nav.by z: (b - a) / 200
      else
        Nav.by
          x: e.touches[0].clientX - lastTouches[0].clientX
          y: e.touches[0].clientY - lastTouches[0].clientY
      cloneTouches e


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
