Take ["Gradient", "Pressure", "Registry", "ScopeCheck", "SVG"], (Gradient, Pressure, Registry, ScopeCheck, SVG)->
  gradientCount = 0
  
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "stroke", "fill", "pressure", "linearGradient", "radialGradient"
    
    element = scope.element
    childPathStroke = childPathFill = element.querySelector "path"
    isLine = element.getAttribute("id")?.indexOf("Line") > -1
    
    linearGradientName = "LGradient" + gradientCount
    linearGradient = null
    radialGradientName = "RGradient" + gradientCount++
    radialGradient = null
    
    
    stroke = null
    Object.defineProperty scope, 'stroke',
      get: ()-> stroke
      set: (val)->
        if stroke isnt val
          SVG.attr element, "stroke", stroke = val
          if childPathStroke?
            SVG.attr childPathStroke, "stroke", null
            childPathStroke = null
    
    
    fill = null
    Object.defineProperty scope, 'fill',
      get: ()-> fill
      set: (val)->
        if fill isnt val
          SVG.attr element, "fill", fill = val
          if childPathFill?
            SVG.attr childPathFill, "fill", null
            childPathFill = null
    
    
    pressure = null
    Object.defineProperty scope, 'pressure',
      get: ()-> pressure
      set: (val)->
        if pressure isnt val
          pressure = val
          if isLine
            scope.setHydraulicLinePressure pressure
          else
            scope.fill = Pressure scope.pressure
    
    
    scope.linearGradient = (stops..., angle = 0)->
      Gradient.remove linearGradientName
      linearGradient = Gradient.linear linearGradientName, x2:Math.cos(angle * Math.PI/180), y2:Math.sin(angle * Math.PI/180), stops...
      scope.fill = "url(##{linearGradientName})"
    
    
    scope.radialGradient = (stops..., props = {r:0.5})->
      Gradient.remove radialGradientName
      if typeof props is "number"
        props = r:0.5
      radialGradient = Gradient.radial radialGradientName, props, stops...
      scope.fill = "url(##{radialGradientName})"
