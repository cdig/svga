Take ["Pressure", "Reaction", "Symbol"], (Pressure, Reaction, Symbol)->
  Symbol "HydraulicLine", [], (svgElement)->
    return scope =
      setup: ()->
        Reaction "Schematic:Show", ()-> scope.pressure = Pressure.black
