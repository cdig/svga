Take ["Action", "Ease", "Reaction", "SVG"], (Action, Ease, Reaction, SVG)->

  Reaction "Background:Set", (v)->
    SVG.style document.body, "background-color", v

    # We need to give the SVG element a background color,
    # or else the background will be black when fullscreen
    SVG.style SVG.svg, "background-color", v

  Reaction "Background:Lightness", (v)->
    hue = Ease.linear v, 0, 1, 227, 218
    Action "Background:Set", "hsl(#{hue}, 5%, #{v*100|0}%)"
