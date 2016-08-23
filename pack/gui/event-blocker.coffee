Take ["Dev", "Nav"], (Dev, Nav)->
  
  # Disable the content menu, so that we can use long-press on touch Windows for pushButtons
  if not Dev
    window.addEventListener "contextmenu", (e)-> e.preventDefault()

  # Block drag-to-copy on Windows
  window.addEventListener "dragstart", (e)-> e.preventDefault()
  
  # Block scrolling on desktops
  window.addEventListener "scroll", (e)-> e.preventDefault()

  # Block scrolling on iOS
  if Nav
    window.addEventListener "touchmove", (e)-> e.preventDefault()
