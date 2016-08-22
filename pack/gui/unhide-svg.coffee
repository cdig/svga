# The SVG starts off hidden. We unhide it when the time comes.

Take ["Dev", "RAF", "Tween", "AllReady"], (Dev, RAF, Tween)->
  if Dev
    RAF ()-> document.querySelector("svg").style.opacity = 1
  else
    Tween 0, 1, .5, (v)-> document.querySelector("svg").style.opacity = v
