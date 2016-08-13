Take ["Ease", "FPS", "Gradient", "Input", "SVG", "Tick", "SVGReady"], (Ease, FPS, Gradient, Input, SVG, Tick)->
  
  activeHighlight = null
  counter = 0
  lgradient = Gradient.linear "LightHighlightGradient", gradientUnits: "userSpaceOnUse", "#9FC", "#FF8", "#FD8"
  mgradient = Gradient.linear "MidHighlightGradient",   gradientUnits: "userSpaceOnUse", "#2F6", "#FF2", "#F72"
  dgradient = Gradient.linear "DarkHighlightGradient",  gradientUnits: "userSpaceOnUse", "#0B3", "#DD0", "#D50"
  
  Tick (time)->
    if activeHighlight? and FPS() > 20
      if ++counter%3 is 0
        props =
          x1:Math.cos(time * Math.PI) * -60 - 50
          y1:Math.sin(time * Math.PI) * -60 - 50
          x2:Math.cos(time * Math.PI) *  60 - 50
          y2:Math.sin(time * Math.PI) *  60 - 50
        Gradient.updateProps lgradient, props
        Gradient.updateProps mgradient, props
        Gradient.updateProps dgradient, props
  
  
  Make "Highlight", (targets...)->
    elements = []
    active = false
    timeout = null
    
    
    setup = (elm)->
      fill = SVG.attr elm, "fill"
      stroke = SVG.attr elm, "stroke"
      doFill = fill? and fill isnt "none" and fill isnt "transparent"
      doStroke = stroke? and stroke isnt "none" and stroke isnt "transparent"
      if doFill or doStroke
        elements.push e = elm: elm, attrs: {}
        e.attrs.fill = fill if doFill
        e.attrs.stroke = stroke if doStroke
        e.attrs.strokeWidth = width if doStroke and (width = SVG.attr elm, "stroke-width")?
      for elm in elm.childNodes
        if elm.tagName is "g" or elm.tagName is "path" or elm.tagName is "text" or elm.tagName is "tspan" or elm.tagName is "rect" or elm.tagName is "circle"
          setup elm
    
    
    for target in targets
      if not target? then console.log targets; throw "Highlight called with a null element ^^^"
      t = target.element or target # Support both scopes and elements
      unless t._HighlighterSetup
        t._HighlighterSetup = true
        setup t
    
    
    activate = ()->
      if not active
        active = true
        activeHighlight?() # Deactivate any active highlight
        activeHighlight = deactivate # Set this to be the new active highlight
        for e in elements
          if e.attrs.stroke?
            if e.attrs.stroke is "#FFF" or e.attrs.stroke is "white"
              SVG.attrs e.elm, stroke: "url(#LightHighlightGradient)", strokeWidth: 3
            else if e.attrs.stroke is "#000" or e.attrs.stroke is "black"
              SVG.attrs e.elm, stroke: "url(#DarkHighlightGradient)", strokeWidth: 3
            else
              SVG.attrs e.elm, stroke: "url(#MidHighlightGradient)", strokeWidth: 3
          if e.attrs.fill?
            if e.attrs.fill is "#FFF" or e.attrs.fill is "white"
              SVG.attrs e.elm, fill: "url(#LightHighlightGradient)"
            else if e.attrs.fill is "#000" or e.attrs.fill is "black"
              SVG.attrs e.elm, fill: "url(#DarkHighlightGradient)"
            else
              SVG.attrs e.elm, fill: "url(#MidHighlightGradient)"
        timeout = setTimeout deactivate, 4000
    
    
    deactivate = ()->
      if active
        active = false
        clearTimeout timeout
        activeHighlight = null
        for e in elements
          SVG.attrs e.elm, e.attrs

    
    for target in targets
      t = target.element or target # Support both scopes and elements
      unless t._Highlighter
        t._Highlighter = true
        
        # Handle Mouse and Touch differently, for better perf
        mouseProps =
          moveIn: activate
          click: activate
        touchProps =
          down: activate
        
        Input t, mouseProps, true, false
        Input t, touchProps, false, true
