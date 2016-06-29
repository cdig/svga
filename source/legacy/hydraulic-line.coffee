Take ["Reaction", "SVG", "Symbol"], (Reaction, SVG, Symbol)->
  Symbol "HydraulicLine", [], (svgElement)->
    return scope =
      setup: ()->
        Reaction "Schematic:Hide", ()-> SVG.attr svgElement, "filter", null
        Reaction "Schematic:Show", ()-> SVG.attr svgElement, "filter", "url(#allblackMatrix)"
  
  SVG.createColorMatrixFilter "allblackMatrix",  "0 0 0 0 0
                                                  0 0 0 0 0
                                                  0 0 0 0 0
                                                  0 0 0 1 0"
