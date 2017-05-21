Take ["Mode", "Nav"], (Mode, Nav)->
  return unless Mode.nav
  
  # This only works in Safari and Mobile Safari
  # On Mobile Safari, it fights a bit with touchmove.
  # One of them will win and overwrite the other. Not a big deal.
  
  window.addEventListener "gesturestart", (e)->
    if Nav.eventInside e
      e.preventDefault()
      Nav.startScale()
  
  window.addEventListener "gesturechange", (e)->
    if Nav.eventInside e
      e.preventDefault()
      Nav.scale e.scale
