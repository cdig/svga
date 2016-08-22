Take ["Action", "Config", "ParentObject", "Reaction", "SVG"], (Action, Config, ParentObject, Reaction, SVG)->
  
  # Set to a specific color
  if typeof Config.background is "string"
    SVG.style ParentObject, "background-color", Config.background
  
  # Allow adjustment, default to grey
  else if Config.background is true
    Reaction "Background:Set", (v)-> SVG.style ParentObject, "background-color", "hsl(227, 5%, #{v*100}%)"
    Take "SceneReady", ()-> Action "Background:Set", .70
  
  # No background
  else
    SVG.style ParentObject, "background-color", "transparent"
