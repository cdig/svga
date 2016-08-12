Take ["Ease", "FPS", "Gradient", "Input", "SVG", "Tick", "SVGReady"], (Ease, FPS, Gradient, Input, SVG, Tick)->
  
  highlightedCount = 0
  gradient = Gradient.linear "HighlightGradient", gradientUnits: "userSpaceOnUse", "#1E5", "#FF0", "#F70"
  
  counter = 0
  
  Tick (time)->
    if highlightedCount > 0 and FPS() > 30 and ++counter%2 is 0
      Gradient.updateProps gradient,
        x1:Math.cos(time * Math.PI) * -60 - 50
        y1:Math.sin(time * Math.PI) * -60 - 50
        x2:Math.cos(time * Math.PI) *  60 - 50
        y2:Math.sin(time * Math.PI) *  60 - 50

  
  Make "Highlight", (targets...)->
    elements = []
    active = false
    timeout = null
    
    setup = (elm)->
      if elm.tagName is "path" or elm.tagName is "rect"
        elements.push
          elm: elm
          stroke: SVG.attr elm, "stroke"
          width: SVG.attr elm, "strokeWidth"
      else if elm.tagName is "tspan" or elm.tagName is "text"
        elements.push
          elm: elm
          fill: SVG.attr elm, "fill"
        
      for elm in elm.childNodes
        setup elm
    
    activate = ()->
      if not active
        active = true
        highlightedCount++
        for e in elements
          if e.stroke?
            SVG.attrs e.elm, stroke: "url(#HighlightGradient)", strokeWidth: 3
          else
            SVG.attrs e.elm, fill: "url(#HighlightGradient)"
        timeout = setTimeout deactivate, 4000
    
    deactivate = ()->
      if active
        active = false
        highlightedCount--
        for e in elements
          if e.stroke?
            SVG.attrs e.elm, stroke: e.stroke, strokeWidth: e.width
          else
            SVG.attrs e.elm, fill: e.fill
        clearTimeout timeout
    
    for target in targets
      if not target? then console.log targets; throw "Highlight called with a null element ^^^"
      
      t = target.element or target # Support both scopes and elements
      setup t
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
