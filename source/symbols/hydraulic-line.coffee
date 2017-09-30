Take ["Pressure", "Reaction", "SVG", "Symbol"], (Pressure, Reaction, SVG, Symbol)->
  Symbol "HydraulicLine", [], (element)->
    strokeElms = []
    fillElms = []
    highlightActive = false
    
    
    strip = (elm)->
      if elm.hasAttribute?("fill") and elm.getAttribute("fill") isnt "none"
        fillElms.push elm if elm isnt element
        elm.removeAttribute "fill"
      if elm.hasAttribute?("stroke") and elm.getAttribute("stroke") isnt "none"
        strokeElms.push elm if elm isnt element
        elm.removeAttribute "stroke"
      if elm.childNodes.length
        strip child for child in elm.childNodes
      undefined

    strip element
    element.setAttribute "fill", "transparent"
    
    
    apply = (stroke, fill = stroke)->
      for elm in strokeElms
        SVG.attr elm, "stroke", stroke
      for elm in fillElms
        SVG.attr elm, "fill", fill
      undefined
    
    
    return scope =
      _highlight: (enable)->
        if highlightActive = enable
          apply "url(#MidHighlightGradient)", "url(#LightHighlightGradient)"
        else
          apply Pressure scope.pressure # scope, not @, because binding doesn't seem to stick when using => here * shrug *
      
      _setPressure: (p)->
        apply Pressure p unless highlightActive
      
      setup: ()->
        @pressure = 0
        Reaction "Schematic:Show", ()-> @pressure = Pressure.black
