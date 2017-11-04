Take ["Pressure", "Reaction", "Symbol"], (Pressure, Reaction, Symbol)->
  Symbol "BackgroundCover", [], (svgElement)->
    return scope =
      setup: ()->
        Reaction "Background:Set", (v)->
          scope.fill = v
