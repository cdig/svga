# We wait for SymbolsReady so that we don't trigger it ourselves, prematurely
Take ["Reaction", "SVG", "Symbol", "SymbolsReady"], (Reaction, SVG, Symbol)->
  Symbol "HydraulicLine", [], (svgElement)->
    return scope =
      setup: ()->
        Reaction "Schematic:Hide", ()-> svgElement.removeAttribute "filter"
        Reaction "Schematic:Show", ()-> svgElement.setAttribute "filter", "url(#allblackMatrix)"
  
  SVG.createColorMatrixFilter "allblackMatrix",  "0   0   0    0   0
                                                  0   0   0    0   0
                                                  0   0   0    0   0
                                                  0   0   0    1   0"
