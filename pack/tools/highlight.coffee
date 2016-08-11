Take ["Ease", "Gradient", "Input", "SVG", "Tick", "SVGReady"], (Ease, Gradient, Input, SVG, Tick)->
  
  highlightedCount = 0
  
  Tick (time)->
    if highlightedCount > 0
      Gradient.remove "HighlightGradient"
      props =
        x1:Math.cos(time * Math.PI) * -60 - 50
        y1:Math.sin(time * Math.PI) * -60 - 50
        x2:Math.cos(time * Math.PI) *  60 - 50
        y2:Math.sin(time * Math.PI) *  60 - 50
        gradientUnits: "userSpaceOnUse"
      Gradient.linear "HighlightGradient", props, "#0F5", "#FF0", "#FB2"
  
  
  Make "Highlight", (targets...)->
    elements = []
    active = false
    
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
          SVG.attrs e.elm, stroke: "url(#HighlightGradient)", strokeWidth: 2
    
    deactivate = ()->
      if active
        active = false
        highlightedCount--
        for e in elements
          SVG.attrs e.elm, stroke: e.stroke, strokeWidth: e.width
    
    for target in targets
      t = target.element or target # Support both scopes and elements
      setup t
      unless t._Highlighter
        t._Highlighter = true
        Input t,
          moveIn: activate
          moveOut: deactivate
          dragOut: deactivate
