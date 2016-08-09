Take ["Pressure", "Reaction", "Symbol"], (Pressure, Reaction, Symbol)->
  Symbol "HydraulicField", [], (svgElement)->
    return scope =
      setup: ()->
        @pressure = 0
        
        isInsideOtherField = false
        p = @parent
        while p? and not isInsideOtherField
          isInsideOtherField = p._symbol is @_symbol
          p = p.parent
        
        if not isInsideOtherField
          Reaction "Schematic:Show", ()-> @pressure = Pressure.white
