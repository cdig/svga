Take ["Reaction", "SVG", "Tween1", "ScopeReady"], (Reaction, SVG, Tween1)->
  
  alpha = 1
  root = document.querySelector "#root"
  
  tick = (v)->
    root._scope.alpha = alpha = v
  
  Reaction "Root:Show", ()-> Tween1 alpha, 1, 1.2, tick
  Reaction "Root:Hide", ()-> Tween1 alpha, -1, 1.2, tick
