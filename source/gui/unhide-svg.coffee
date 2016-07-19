# The SVG starts off hidden. We unhide it when the time comes.

Take ["Env", "Tween1", "ScopeReady"], (Env, Tween1)->
  if Env.dev
    setTimeout ()-> document.rootElement.style.opacity = 1
  else
    Tween1 0, 1, .5, (v)-> document.rootElement.style.opacity = v
