do ()->
  
  # Block scrolling on iOS
  window.addEventListener "touchmove", (e)-> e.preventDefault()
  
  # Block scrolling on desktops
  window.addEventListener "scroll", (e)-> e.preventDefault()
  
  # Block drag-to-copy on Windows
  window.addEventListener "dragstart", (e)-> e.preventDefault()
