Take ["Action", "Mode", "ParentElement", "Reaction", "SVG"], (Action, Mode, ParentElement, Reaction, SVG)->
  
  # Set to a specific color
  if typeof Mode.background is "string"
    SVG.style ParentElement, "background-color", Mode.background
  
  # Allow adjustment, default to grey
  else if Mode.background is true
    Reaction "Background:Set", (v)-> SVG.style ParentElement, "background-color", "hsl(227, 5%, #{v*100}%)"
    Take "SceneReady", ()-> Action "Background:Set", .70
  
  # No background
  else
    SVG.style ParentElement, "background-color", "transparent"
