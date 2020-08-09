Take ["Pressure", "SVG", "Symbol", "Voltage"], (Pressure, SVG, Symbol, Voltage)->
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


    applyColor = (stroke, fill = stroke)->
      for elm in strokeElms
        SVG.attr elm, "stroke", stroke
      for elm in fillElms
        SVG.attr elm, "fill", fill
      undefined


    return scope =
      _highlight: (enable)->
        if highlightActive = enable
          applyColor "url(#MidHighlightGradient)", "url(#LightHighlightGradient)"
        else if scope.voltage?
          applyColor Voltage scope.voltage
        else
          applyColor Pressure scope.pressure

      _setColor: (p)->
        if highlightActive
          # Do nothing
        else if scope.voltage?
          applyColor Voltage p
        else
          applyColor Pressure p

      setup: ()->
        @pressure = 0

        # If there's a dashed child of this HydraulicLine, turn it into a pilot line
        @dashed?.dash.pilot()
