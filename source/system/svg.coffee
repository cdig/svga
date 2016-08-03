# These are Ivan's SVG tools. They're private APIs, part of the implementation of SVGA.
# They're not to be used by content, since they might endure breaking changes at any time.
# They may be used by Controls, since those are a more advanced feature of SVGA.

do ()->
  
  root = document.rootElement
  defs = root.querySelector "defs"
  
  svgNS = "http://www.w3.org/2000/svg"
  xlinkNS = "http://www.w3.org/1999/xlink"
  props =
    textContent: true
    # additional props will be listed here as needed
  
  # We wait for the SVGReady event, fired by core/main.coffee, to tell us that it's safe to mutate the DOM.
  SVGReady = false
  
  
  SVG =
    root: root
    defs: defs
    
    move: (elm, x, y = 0)-> throw "Don't use SVG.move()"
    rotate: (elm, r)-> throw "Don't use SVG.rotate()"
    origin: (elm, ox, oy)-> throw "Don't use SVG.origin()"
    scale: (elm, x, y = x)-> throw "Don't use SVG.scale()"
    
    create: (type, parent, attrs)->
      elm = document.createElementNS svgNS, type
      SVG.attrs elm, attrs if attrs?
      SVG.append parent, elm if parent?
      elm # Composable
    
    clone: (source, parent, attrs)->
      throw "Clone source is undefined in SVG.clone(source, parent, attrs)" unless source?
      throw "SVG.clone() called before SVGReady" unless SVGReadyForMutation()
      elm = document.createElementNS svgNS, "g"
      SVG.attr elm, attr.name, attr.value for attr in source.attributes
      SVG.attrs elm, id: null
      SVG.attrs elm, attrs if attrs?
      SVG.append elm, child.cloneNode true for child in source.childNodes
      SVG.append parent, elm if parent?
      elm # Composable
    
    append: (parent, child)->
      throw "SVG.append() called before SVGReady" unless SVGReadyForMutation()
      parent.appendChild child
      child # Composable
    
    prepend: (parent, child)->
      throw "SVG.prepend() called before SVGReady" unless SVGReadyForMutation()
      if parent.hasChildNodes()
        parent.insertBefore child, parent.firstChild
      else
        parent.appendChild child
      child # Composable
    
    attrs: (elm, attrs)->
      unless elm then throw "SVG.attrs was called with a null element"
      unless typeof attrs is "object" then console.log attrs; throw "SVG.attrs requires an object as the second argument, got ^"
      for k, v of attrs
        SVG.attr elm, k, v
      elm # Composable
    
    attr: (elm, k, v)->
      unless elm then throw "SVG.attr was called with a null element"
      unless typeof k is "string" then console.log k; throw "SVG.attr requires a string as the second argument, got ^^^"
      elm._SVG_attr ?= {}
      # Note that we only do DOM->cache on a read call (not on a write call),
      # to slightly avoid intermingling DOM reads and writes, which causes thrashing.
      return elm._SVG_attr[k] ?= elm.getAttribute(k) if v is undefined # Read.
      return v if elm._SVG_attr[k] is v # cache hit — bail
      elm._SVG_attr[k] = v # update cache
      return elm[k] = v if props[k]? # set DOM property
      ns = if k is "xlink:href" then xlinkNS else null
      # Turn camelCase into kebab-case, for convenience.
      # CAUTION: This might cause cross-browser issues. If it does, handle this the way we handle props — a hash lookup.
      _k = k.replace(/([A-Z])/g,"-$1").toLowerCase()
      if v?
        elm.setAttributeNS ns, _k, v # set DOM attribute
      else
        elm.removeAttributeNS ns, _k # remove DOM attribute
      return v # Not Composable

    styles: (elm, styles)->
      unless elm then throw "SVG.styles was called with a null element"
      unless typeof styles is "object" then console.log styles; throw "SVG.styles requires an object as the second argument, got ^"
      SVG.style elm, k, v for k, v of styles
      elm # Composable
    
    style: (elm, k, v)->
      unless elm then throw "SVG.style was called with a null element"
      unless typeof k is "string" then console.log k; throw "SVG.style requires a string as the second argument, got ^"
      elm._SVG_style ?= {}
      return elm._SVG_style[k] ?= elm.style[k] if v is undefined
      if elm._SVG_style[k] isnt v
        elm.style[k] = elm._SVG_style[k] = v
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
  
  
  SVGReadyForMutation = ()->
    # We have to do some extra nonsense to check that SVGReady has been fired,
    # because other systems that want to use us might have SVGReady fire for them
    # before it fires for us. So, the first time we run, we'll do a synchronous
    # take to make sure that SVGReady has indeed fired, and that we're not being
    # called by a system too early in initialization (ie: before it's safe to
    # mutate the DOM).
    return SVGReady or (SVGReady = Take "SVGReady")
  
  
  Make "SVG", SVG
