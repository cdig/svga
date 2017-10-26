Take ["Action", "Mode", "ParentElement", "Reaction", "SVG"], (Action, Mode, ParentElement, Reaction, SVG)->
  
  Reaction "Background:Set", (v)->
    SVG.style ParentElement, "background-color", v
  
  Reaction "Background:Lightness", (v)->
    Action "Background:Set", "hsl(227, 5%, #{v*100|0}%)"
  
  # Set up the initial background
  if typeof Mode.background is "string"
    Action "Background:Set", Mode.background
  else if Mode.background is true
    Take "SceneReady", ()-> Action "Background:Lightness", .7
  else
    Action "Background:Set", "transparent"
