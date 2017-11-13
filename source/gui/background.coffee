Take ["Action", "Ease", "ParentElement", "Reaction", "SVG"], (Action, Ease, ParentElement, Reaction, SVG)->
  
  Reaction "Background:Set", (v)->
    SVG.style ParentElement, "background-color", v
  
  Reaction "Background:Lightness", (v)->
    hue = Ease.linear v, 0, 1, 227, 218
    Action "Background:Set", "hsl(#{hue}, 5%, #{v*100|0}%)"
