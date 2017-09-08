# The SVG starts off hidden. We unhide it when the time comes.

Take ["Mode", "RAF", "SVG", "Tween", "AllReady"], (Mode, RAF, SVG, Tween)->
  
  if Mode.dev
    RAF ()-> SVG.svg.style.opacity = 1
  
  else
    Tween 0, 1, .5, (v)-> SVG.svg.style.opacity = v
