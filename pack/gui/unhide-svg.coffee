# The SVG starts off hidden. We unhide it when the time comes.

Take ["Mode", "RAF", "Tween", "AllReady"], (Mode, RAF, Tween)->
  if Mode.dev
    RAF ()-> document.querySelector("svg").style.opacity = 1
  else
    Tween 0, 1, .5, (v)-> document.querySelector("svg").style.opacity = v
