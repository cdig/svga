# We wait for SymbolsReady so that we don't trigger it ourselves, prematurely
Take ["Reaction", "SVG", "Symbol", "SymbolsReady"], (Reaction, SVG, Symbol)->
  Symbol "HydraulicLine", [], (svgElement)->
    return scope =
      setup: ()->
        Reaction "animateMode", ()-> svgElement.removeAttribute "filter"
        Reaction "schematicMode", ()-> svgElement.setAttribute "filter", "url(#allblackMatrix)"
  
  SVG.createColorMatrix "allblackMatrix",  "0   0   0    0   0
                                            0   0   0    0   0
                                            0   0   0    0   0
                                            0   0   0    1   0"
