Take ["Nav"], (Nav)->
  
  window.addEventListener "gesturestart", (e)->
    e.preventDefault()
    Nav.startScale()
  
  window.addEventListener "gesturechange", (e)->
    e.preventDefault()
    Nav.scale e.scale
