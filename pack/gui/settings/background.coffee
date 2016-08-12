Take ["Action", "Config", "ParentObject", "Reaction", "SVG"], (Action, Config, ParentObject, Reaction, SVG)->
  
  # Set to a specific color
  if typeof Config.background is "string"
    SVG.style ParentObject, "background-color", Config.background
  
  # Allow adjustment, default to grey
  else if Config.background
    setBackground = (v)->
      c = "hsl(227, 5%, #{v*100}%)"
      SVG.style ParentObject, "background-color", c
    
    Reaction "Background:Set", setBackground
    
    Take "ScopeReady", ()->
      Action "Background:Set", .70
  
  # No background
  else
    SVG.style ParentObject, "background-color", "transparent"
