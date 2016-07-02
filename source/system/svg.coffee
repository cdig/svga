# These are Ivan's SVG tools. They're private APIs, part of the implementation of SVGA.
# They're not to be used by content, since they might endure breaking changes at any time.

# We wait for the SVGReady event, fired by core/main.coffee, to tell us that it's safe to mutate the DOM.
Take ["SVGReady"], ()->
  
  root = document.rootElement
  defs = root.querySelector "defs"
  
  svgNS = "http://www.w3.org/2000/svg"
  xlinkNS = "http://www.w3.org/1999/xlink"
  props =
    textContent: true
    # additional props will be listed here as needed
  
  
  Make "SVG", SVG =
    root: root
    defs: defs
    
    move: (elm, x, y = 0)-> throw "MOVE"
    rotate: (elm, r)-> throw "ROTATE"
    origin: (elm, ox, oy)-> throw "ORIGIN"
    scale: (elm, x, y = x)-> throw "SCALE"
    
    create: (type, parent, attrs)->
      elm = document.createElementNS svgNS, type
      SVG.attrs elm, attrs if attrs?
      SVG.append parent, elm if parent?
      elm # Composable
    
    clone: (source, parent, attrs)->
      throw "Clone source is undefined in SVG.clone(source, parent, attrs)" unless source?
      elm = document.createElementNS svgNS, "g"
      SVG.attr elm, attr.name, attr.value for attr in source.attributes
      SVG.attrs elm, id: null
      SVG.attrs elm, attrs if attrs?
      SVG.append elm, child.cloneNode true for child in source.childNodes
      SVG.append parent, elm if parent?
      elm # Composable
    
    append: (parent, child)->
      parent.appendChild child
      child # Composable
    
    prepend: (parent, child)->
      if parent.hasChildNodes()
        parent.insertBefore child, parent.firstChild
      else
        parent.appendChild child
      child # Composable
    
    attrs: (elm, attrs)->
      unless elm then throw "SVG.attrs was called with a null element"
      unless typeof attrs is "object" then console.log attrs; throw "SVG.attrs requires an object as the second argument, got ^"
      SVG.attr elm, k, v for k, v of attrs
      elm # Composable
    
    attr: (elm, k, v)->
      unless elm then throw "SVG.attr was called with a null element"
      unless typeof k is "string" then console.log k; throw "SVG.attr requires a string as the second argument, got ^"
      return elm.getAttribute k if v is undefined
      elm._SVG ?= {}
      if elm._SVG[k] isnt v
        elm._SVG[k] = v
        if props[k]?
          elm[k] = v
        else if v?
          ns = if k is "xlink:href" then xlinkNS else null
          elm.setAttributeNS ns, k, v
        else
          ns = if k is "xlink:href" then xlinkNS else null
          elm.removeAttributeNS ns, k
      v # Not Composable
    
    grey: (elm, l)->
      SVG.attr elm, "fill", "hsl(0, 0%, #{l*100}%)"
      elm # Composable

    hsl: (elm, h, s, l)->
      SVG.attr elm, "fill", "hsl(#{h*360}, #{s*100}%, #{l*100}%)"
      elm # Composable
    
    createGradient: (name, vertical, stops...)->
      attrs = if vertical then { id: name, x2: 0, y2: 1 } else { id: name }
      gradient = SVG.create "linearGradient", defs, attrs
      createStops gradient, stops
      gradient # Not Composable
    
    createRadialGradient: (name, stops...)->
      gradient = SVG.create "radialGradient", defs, id: name
      createStops gradient, stops
      gradient # Not Composable
    
    createColorMatrixFilter: (name, values)->
      filter = SVG.create "filter", defs, id: name
      SVG.create "feColorMatrix", filter, in: "SourceGraphic", type: "matrix", values: values
      filter # Not Composable
  
  
  createStops = (gradient, stops)->
    stops = if stops[0] instanceof Array then stops[0] else stops
    for stop, i in stops
      attrs = if typeof stop is "string"
        { "stop-color": stop, offset: (100 * i/(stops.length-1)) + "%" }
      else
        { "stop-color": stop.color, offset: (100 * stop.offset) + "%" }
      SVG.create "stop", gradient, attrs
    null # Not Composable
