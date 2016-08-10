Take ["Pressure", "Reaction", "SVG", "Symbol"], (Pressure, Reaction, SVG, Symbol)->
  Symbol "HydraulicLine", [], (element)->
    strokeElms = []
    fillElms = []
    
    strip = (elm)->
      if elm.hasAttribute?("fill") and elm.getAttribute("fill") isnt "none"
        fillElms.push elm if elm isnt element
        elm.removeAttribute "fill"
      if elm.hasAttribute?("stroke") and elm.getAttribute("stroke") isnt "none"
        strokeElms.push elm if elm isnt element
        elm.removeAttribute "stroke"
      if elm.childNodes.length
        strip child for child in elm.childNodes
    strip element
    element.setAttribute "fill", "transparent"
    
    return scope =
      setHydraulicLinePressure: (pressure)->
        p = Pressure pressure
        for elm in strokeElms
          SVG.attr elm, "stroke", p
        for elm in fillElms
          SVG.attr elm, "fill", p

      setup: ()->
        @pressure = 0
        Reaction "Schematic:Show", ()-> @pressure = Pressure.black
