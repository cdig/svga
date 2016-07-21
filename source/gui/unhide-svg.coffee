# The SVG starts off hidden. We unhide it when the time comes.

Take ["Env", "RAF", "Tween1", "AllReady"], (Env, RAF, Tween1)->
  if Env.dev
    RAF ()-> document.rootElement.style.opacity = 1
  else
    Tween1 0, 1, .5, (v)-> document.rootElement.style.opacity = v
