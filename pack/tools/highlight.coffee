Take ["Ease", "Gradient", "Input", "SVG", "Tick", "SVGReady"], (Ease, Gradient, Input, SVG, Tick)->
  
  highlightedCount = 0
  
  createGradient = (time)->
    props =
      x1:Math.cos(time * Math.PI) * -60 - 50
      y1:Math.sin(time * Math.PI) * -60 - 50
      x2:Math.cos(time * Math.PI) *  60 - 50
      y2:Math.sin(time * Math.PI) *  60 - 50
      gradientUnits: "userSpaceOnUse"
    Gradient.linear "HighlightGradient", props, "#0F5", "#FF0", "#F70"
  
  counter = 0
  
  Tick (time)->
    if highlightedCount > 0 and ++counter%5 is 0
      Gradient.remove "HighlightGradient"
      createGradient time
  
  createGradient 0
  
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
      for elm in elm.childNodes
        setup elm
    
    activate = ()->
      if not active
        active = true
        highlightedCount++
        for e in elements
          SVG.attrs e.elm, stroke: "url(#HighlightGradient)", strokeWidth: 3
        timeout = setTimeout deactivate, 3000
    
    deactivate = ()->
      if active
        active = false
        highlightedCount--
        for e in elements
          SVG.attrs e.elm, stroke: e.stroke, strokeWidth: e.width
        clearTimeout timeout
    
    for target in targets
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
