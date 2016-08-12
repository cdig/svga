# Depends on style

Take ["Gradient", "Registry", "ScopeCheck"], (Gradient, Registry, ScopeCheck)->
  gradientCount = 0
  
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "linearGradient", "radialGradient"
    
    gradientCount++
    linearGradient = null
    radialGradient = null
    
    lGradName = "LGradient" + gradientCount
    lGradAngle = null
    lGradStops = null

    rGradName = "RGradient" + gradientCount
    rGradProps = null
    rGradStops = null
    
    
    scope.linearGradient = (stops..., angle)->
      linearGradient ?= Gradient.linear lGradName
      if typeof angle is "string"
        stops.push angle
        angle = 0
      if lGradAngle isnt angle
        lGradAngle = angle
        Gradient.updateProps linearGradient, x2:Math.cos(angle * Math.PI/180), y2:Math.sin(angle * Math.PI/180)
      if lGradStops isnt stops
        lGradStops = stops
        Gradient.updateStops linearGradient, stops...
      scope.fill = "url(##{lGradName})"
    
    
    scope.radialGradient = (stops..., props)->
      radialGradient ?= Gradient.radial rGradName
      if typeof props is "number"
        props = r:props
      else if typeof props is "string"
        stops.push props
        props = r:0.5
      if rGradProps isnt props
        rGradProps = props
        Gradient.updateProps radialGradient, props
      if rGradStops isnt stops
        rGradStops = stops
        Gradient.updateStops radialGradient, stops...
      scope.fill = "url(##{rGradName})"
