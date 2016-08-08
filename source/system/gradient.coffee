# Gradient
# Even if we aren't using this anywhere, we'll probably want to
# keep it around for possible future use because SVG gradients are non-trivial.

Take "SVG", (SVG)->
  existing = {}
  
  Make "Gradient", Gradient =
    linear: (name, props, stops...)->
      if existing[name]? then throw "Gradient named #{name} already exists. Please don't create the same gradient more than once."
      existing[name] = true
      attrs = if typeof props is "object"
        props.id = name
        props
      else if props is true # Vertical
        id: name, x2: 0, y2: 1
      else
        id: name
      gradient = SVG.create "linearGradient", SVG.defs, attrs
      createStops gradient, stops
      return gradient # Composable
    
    radial: (name, props, stops...)->
      if existing[name]? then throw "Gradient named #{name} already exists. Please don't create the same gradient more than once."
      existing[name] = true
      props.id = name
      gradient = SVG.create "radialGradient", SVG.defs, props
      createStops gradient, stops
      return gradient # Composable
  
  
  createStops = (gradient, stops)->
    stops = if stops[0] instanceof Array then stops[0] else stops
    for stop, i in stops
      if typeof stop is "string"
        SVG.create "stop", gradient, stopColor: stop, offset: (100 * i/(stops.length-1)) + "%"
      else
        attrs =
          stopColor: stop.color
          offset: 100 * (if stop.offset? then stop.offset else i/(stops.length-1)) + "%"
        attrs.stopOpacity = stop.opacity if stop.opacity?
        SVG.create "stop", gradient, attrs
    null # Not Composable
