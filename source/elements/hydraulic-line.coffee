# We wait for SymbolsReady so that we don't trigger it ourselves, prematurely
Take ["Reaction", "Symbol", "SymbolsReady"], (Reaction, Symbol)->
  Symbol "HydraulicLine", [], (svgElement)->
    return scope =
      setup: ()->
        Reaction "animateMode", ()-> svgElement.removeAttribute "filter"
        Reaction "schematicMode", ()-> svgElement.setAttribute "filter", "url(#allblackMatrix)"
