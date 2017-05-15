Take ["Pressure", "SVG"], (Pressure, SVG)->
  existing = {}
  
  Make "Gradient", Gradient =
    remove: (name)->
      if existing[name]?
        SVG.defs.removeChild existing[name]
        delete existing[name]
    
    updateStops: (gradient, stops...)->
      if gradient._stops?
        dirty = false
        for stop, i in gradient._stops
          dirty = if stop.color? and stops[i].color?
            stop.color isnt stops[i].color or stop.offset isnt stops[i].offset or stop.opacity isnt stops[i].opacity
          else
            stop isnt stops[i]
          break if dirty
        return unless dirty
      
      gradient._stops = stops
      
      while gradient.hasChildNodes()
        gradient.removeChild gradient.lastChild
      stops = if stops[0] instanceof Array then stops[0] else stops
      for stop, i in stops
        if typeof stop is "string"
          SVG.create "stop", gradient, stopColor: stop, offset: (100 * i/(stops.length-1)) + "%"
        else if typeof stop is "number"
          SVG.create "stop", gradient, stopColor: Pressure(stop), offset: (100 * i/(stops.length-1)) + "%"
        else
          attrs =
            stopColor: stop.color
            offset: 100 * (if stop.offset? then stop.offset else i/(stops.length-1)) + "%"
          attrs.stopOpacity = stop.opacity if stop.opacity?
          SVG.create "stop", gradient, attrs
      gradient # Composable

    
    updateProps: (gradient, props)->
      SVG.attrs gradient, props
    
    linear: (name, props = {}, stops...)->
      if existing[name]? then throw new Error "Gradient named #{name} already exists. Please don't create the same gradient more than once."
      attrs = if typeof props is "object"
        props.id = name
        props
      else if props is true # Vertical
        id: name, x2: 0, y2: 1
      else
        id: name
      gradient = existing[name] = SVG.create "linearGradient", SVG.defs, attrs
      Gradient.updateStops gradient, stops
      return gradient # Composable
    
    radial: (name, props = {}, stops...)->
      if existing[name]? then throw new Error "Gradient named #{name} already exists. Please don't create the same gradient more than once."
      existing[name] = true
      props.id = name
      gradient = existing[name] = SVG.create "radialGradient", SVG.defs, props
      Gradient.updateStops gradient, stops
      return gradient # Composable
