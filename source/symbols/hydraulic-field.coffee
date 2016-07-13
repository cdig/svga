Take ["Pressure", "Reaction", "Symbol"], (Pressure, Reaction, Symbol)->
  Symbol "HydraulicField", [], (svgElement)->
    return scope =
      setup: ()->
        Reaction "Schematic:Show", ()-> scope.pressure = Pressure.white
