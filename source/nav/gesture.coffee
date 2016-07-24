Take ["Nav"], (Nav)->
  
  window.addEventListener "gesturestart", (e)->
    if Nav.eventInside e
      e.preventDefault()
      Nav.startScale()
  
  window.addEventListener "gesturechange", (e)->
    if Nav.eventInside e
      e.preventDefault()
      Nav.scale e.scale
