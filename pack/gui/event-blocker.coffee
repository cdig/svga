Take "Nav", (Nav)->
  
  # Block scrolling on iOS
  if Nav
    window.addEventListener "touchmove", (e)-> e.preventDefault()
  
  # Block scrolling on desktops
  window.addEventListener "scroll", (e)-> e.preventDefault()
  
  # Block drag-to-copy on Windows
  window.addEventListener "dragstart", (e)-> e.preventDefault()
