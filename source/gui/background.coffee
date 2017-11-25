Take ["Action", "Ease", "Reaction", "SVG"], (Action, Ease, Reaction, SVG)->
  
  Reaction "Background:Set", (v)->
    SVG.style document.body, "background-color", v
  
  Reaction "Background:Lightness", (v)->
    hue = Ease.linear v, 0, 1, 227, 218
    Action "Background:Set", "hsl(#{hue}, 5%, #{v*100|0}%)"
