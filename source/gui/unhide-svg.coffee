# The SVG starts off hidden. We unhide it when the time comes.

Take ["Dev", "RAF", "Tween1", "AllReady"], (Dev, RAF, Tween1)->
  if Dev
    RAF ()-> document.rootElement.style.opacity = 1
  else
    Tween1 0, 1, .5, (v)-> document.rootElement.style.opacity = v
