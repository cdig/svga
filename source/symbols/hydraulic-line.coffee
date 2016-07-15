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
      pilot: (name)->
        if not scope[name]? then throw "#{scope.name}.pilot(\"#{name}\") failed: #{name} is not a child of #{scope.name}"
        for path in scope[name].element.querySelectorAll "path"
          SVG.attrs path, "stroke-dasharray": "6 6"
        
      setup: ()->
        Reaction "Schematic:Show", ()-> scope.pressure = Pressure.black
