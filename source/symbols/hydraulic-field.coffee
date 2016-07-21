Take ["Pressure", "Reaction", "Symbol"], (Pressure, Reaction, Symbol)->
  Symbol "HydraulicField", [], (svgElement)->
    return scope =
      setup: ()->
        
        isInsideOtherField = false
        p = scope.parent
        while p? and not isInsideOtherField
          isInsideOtherField = p._symbol is scope._symbol
          p = p.parent
        
        if not isInsideOtherField
          Reaction "Schematic:Show", ()-> scope.pressure = Pressure.white
