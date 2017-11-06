Take ["Action", "ParentElement", "Reaction", "SVG"], (Action, ParentElement, Reaction, SVG)->
  
  Reaction "Background:Set", (v)->
    SVG.style ParentElement, "background-color", v
  
  Reaction "Background:Lightness", (v)->
    Action "Background:Set", "hsl(227, 5%, #{v*100|0}%)"
