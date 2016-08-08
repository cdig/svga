Take ["Pressure", "Reaction", "SVG", "Symbol"], (Pressure, Reaction, SVG, Symbol)->
  Symbol "HydraulicLine", [], (svgElement)->
    
    strip = (elm)->
      elm.removeAttributeNS? null, "fill"
      elm.removeAttributeNS? null, "stroke"
      if elm.childNodes.length
        strip child for child in elm.childNodes
    
    strip svgElement
    svgElement.setAttributeNS null, "fill", "transparent"
    
    return scope =
      setup: ()->
        Reaction "Schematic:Show", ()-> scope.pressure = Pressure.black
