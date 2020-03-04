Take ["Ease", "Reaction", "Symbol"], (Ease, Reaction, Symbol)->
  Symbol "ManifoldBackground", ["ManifoldBackground"], (svgElement)->
    return scope =
      setup: ()->
        Reaction "Background:Lightness", (v)->
          hue = Ease.linear v, 0, 1, 227, 218
          lightness = v * 100
          lightness += if lightness > 50 then -7 else 7
          scope.fill = "hsl(#{hue}, 5%, #{lightness}%)"
