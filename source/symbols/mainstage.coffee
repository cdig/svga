Take ["Reaction", "Symbol", "Tween1"], (Reaction, Symbol, Tween1)->
  Symbol "MainStage", [], (svgElement)->
    return scope =
      setup: ()->
        tick = (v)-> scope.alpha = v
        Reaction "MainStage:Show", ()-> Tween1 scope.alpha, 1, 0.7, tick
        Reaction "MainStage:Hide", ()-> Tween1 scope.alpha, 0, 0.7, tick
