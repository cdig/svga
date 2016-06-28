# These are Ivan's SVG tools. They're private APIs, part of the implementation of SVGA.
# They're not to be used by content, since they might endure breaking changes at any time.

Take ["DOMContentLoaded"], ()->
  namespaces =
    svg: "http://www.w3.org/2000/svg"
    "xlink:href": "http://www.w3.org/1999/xlink"
  props =
    textContent: true
    # additional props will be listed here as needed
  root = document.querySelector "svg"
  defs = root.querySelector "defs"
  
  Make "SVG", SVG =
    root: root
    defs: defs
    
    move: (elm, x, y = 0)-> throw "MOVE"
    rotate: (elm, r)-> throw "ROTATE"
    origin: (elm, ox, oy)-> throw "ORIGIN"
    scale: (elm, x, y = x)-> throw "SCALE"
    
    create: (type, parent, attrs)->
      elm = document.createElementNS namespaces.svg, type
      SVG.attrs elm, attrs
      SVG.append parent, elm if parent?
      elm # Composable
    
    clone: (source, parent, attrs)->
      elm = document.createElementNS namespaces.svg, "g"
      SVG.attr elm, attr.name, attr.value for attr in source.attributes
      SVG.attrs elm, id: null
      SVG.attrs elm, attrs
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
      SVG.attr elm, k, v for k, v of attrs
      elm # Composable
    
    attr: (elm, k, v)->
      return elm.getAttribute k if v is undefined
      elm._SVG ?= {}
      if elm._SVG[k] isnt v
        elm._SVG[k] = v
        if props[k]?
          elm[k] = v
        else if v?
          elm.setAttributeNS namespaces[k], k, v
        else
          elm.removeAttributeNS namespaces[k], k
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
