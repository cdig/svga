# Gradient
# Even if we aren't using this anywhere, we'll probably want to
# keep it around for possible future use because SVG gradients are non-trivial.

Take "SVG", (SVG)->
  existing = {}
  
  Make "Gradient", Gradient =
    createLinear: (name, vertical, stops...)->
      if existing[name]? then throw "Gradient named #{name} already exists. Please don't create the same gradient more than once."
      existing[name] = true
      attrs = if vertical then { id: name, x2: 0, y2: 1 } else { id: name }
      gradient = SVG.create "linearGradient", SVG.defs, attrs
      createStops gradient, stops
      null # Not Composable
    
    createRadial: (name, stops...)->
      if existing[name]? then throw "Gradient named #{name} already exists. Please don't create the same gradient more than once."
      existing[name] = true
      gradient = SVG.create "radialGradient", SVG.defs, id: name
      createStops gradient, stops
      null # Not Composable
  
  
  createStops = (gradient, stops)->
    stops = if stops[0] instanceof Array then stops[0] else stops
    for stop, i in stops
      attrs = if typeof stop is "string"
        { "stop-color": stop, offset: (100 * i/(stops.length-1)) + "%" }
      else
        { "stop-color": stop.color, offset: (100 * stop.offset) + "%" }
      SVG.create "stop", gradient, attrs
    null # Not Composable
