Take ["Ease", "FPS", "Gradient", "Input", "SVG", "Tick", "SVGReady"], (Ease, FPS, Gradient, Input, SVG, Tick)->
  
  highlightedCount = 0
  gradient = Gradient.linear "HighlightGradient", gradientUnits: "userSpaceOnUse", "#1E5", "#FF0", "#F70"
  
  counter = 0
  
  Tick (time)->
    if highlightedCount > 0 and FPS() > 20 and ++counter%2 is 0
      Gradient.updateProps gradient,
        x1:Math.cos(time * Math.PI) * -60 - 50
        y1:Math.sin(time * Math.PI) * -60 - 50
        x2:Math.cos(time * Math.PI) *  60 - 50
        y2:Math.sin(time * Math.PI) *  60 - 50

  
  Make "Highlight", (targets...)->
    for target in targets
      if not target? then console.log targets; throw "Highlight called with a null element ^^^"
    
    elements = []
    active = false
    timeout = null
    
    setup = (elm, isLine = false, isField = false)->
      
      # We special-case HydraulicLines and HydraulicFills
      # Eg: so that connection nodes get a highlighted fill
      sn = elm._scope?._symbol.symbolName
      isLine ||= sn is "HydraulicLine"
      isField ||= sn is "HydraulicField"
      
      # We also special-case text nodes
      text = elm.tagName is "tspan" or elm.tagName is "text"
      
      if elm.tagName is "path" or elm.tagName is "rect" or text
        elements.push e = elm: elm, attrs: {}
        e.attrs.fill = fill if (text or isLine or isField) and (fill = SVG.attr elm, "fill")? and fill isnt "transparent" and fill isnt "none"
        isNode = isLine and fill? and fill isnt "transparent" and fill isnt "none"
        e.attrs.stroke = stroke if (stroke = SVG.attr elm, "stroke")? and not isNode# and stroke isnt "transparent" and stroke isnt "none")
        e.attrs.strokeWidth = width if width = SVG.attr elm, "stroke-width"
      
      for elm in elm.childNodes
        setup elm, isLine, isField
    
    
    initialSetup = ()->
      for target in targets
        t = target.element or target # Support both scopes and elements
        unless t._HighlighterSetup
          t._HighlighterSetup = true
          setup t
    
    activate = ()->
      initialSetup()
      if not active
        active = true
        highlightedCount++
        for e in elements
          if e.attrs.stroke?
            SVG.attrs e.elm, stroke: "url(#HighlightGradient)", strokeWidth: 3
          if e.attrs.fill?
            SVG.attrs e.elm, fill: "url(#HighlightGradient)"
        timeout = setTimeout deactivate, 4000
    
    
    deactivate = ()->
      if active
        active = false
        highlightedCount--
        for e in elements
          SVG.attrs e.elm, e.attrs
        clearTimeout timeout

    
    for target in targets
      t = target.element or target # Support both scopes and elements
      unless t._Highlighter
        t._Highlighter = true
        
        # Handle Mouse and Touch differently, for better perf
        mouseProps =
          moveIn: activate
          moveOut: deactivate
        touchProps =
          down: activate
        
        Input t, mouseProps, true, false
        Input t, touchProps, false, true
