Take ["Mode"], (Mode)->
  
  if not Mode.dev
    # Disable the content menu, so that we can use long-press on touch Windows for pushButtons
    window.addEventListener "contextmenu", (e)-> e.preventDefault()

  # Block drag-to-copy on Windows
  window.addEventListener "dragstart", (e)-> e.preventDefault()
  
  if Mode.nav
    # Block scrolling on desktops
    window.addEventListener "scroll", (e)-> e.preventDefault()

    # Block scrolling on iOS
    window.addEventListener "touchmove", (e)-> e.preventDefault()
