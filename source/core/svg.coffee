# These are Ivan's SVG tools. They're private APIs, part of the implementation of SVGA.
# They're not to be used by content, since they might endure breaking changes at any time.

Take ["RequestDeferredRender", "DOMContentLoaded"], (RequestDeferredRender)->
  svgNS = "http://www.w3.org/2000/svg"
  xlinkNS = "http://www.w3.org/1999/xlink"
  root = document.querySelector "svg"
  defs = root.querySelector "defs"
  props = textContent: true # additional props will be listed here as needed
  
  Make "SVG", SVG =
    root: root
    defs: defs
    
    create: (type, parent, attrs)->
      elm = document.createElementNS svgNS, type
      makePrivateProps elm
      SVG.attrs elm, attrs
      SVG.append parent, elm if parent?
      elm # Chainable
    
    append: (parent, child)->
      parent.appendChild child
      child # Chainable
    
    prepend: (parent, child)->
      if parent.hasChildNodes()
        parent.insertBefore child, parent.firstChild
      else
        parent.appendChild child
      child # Chainable
    
    attrs: (elm, attrs)->
      SVG.attr elm, k, v for k, v of attrs
      elm # Chainable
    
    attr: (elm, k, v)->
      return elm.getAttribute k unless v?
      if elm._SVG[k] isnt v
        elm._SVG[k] = v
        if k is "xlink:href"
          elm.setAttributeNS xlinkNS, k, v
        else if props[k]?
          elm[k] = v
        else
          elm.setAttribute k, v
      v
    
    move: (elm, x, y = 0)->
      elm._SVG._tx = x
      elm._SVG._ty = y
      RequestDeferredRender elm._SVG._applyTransform, true
      elm # Chainable
    
    rotate: (elm, r, cx, cy)->
      elm._SVG._r = r * 360
      elm._SVG._cx = cx if cx?
      elm._SVG._cy = cy if cy?
      RequestDeferredRender elm._SVG._applyTransform, true
      elm # Chainable
    
    scale: (elm, x, y = x)->
      elm._SVG._sx = x
      elm._SVG._sy = y
      RequestDeferredRender elm._SVG._applyTransform, true
      elm # Chainable
    
    grey: (elm, l)->
      SVG.attr elm, "fill", "hsl(0, 0%, #{l*100}%)"
      elm # Chainable

    hsl: (elm, h, s, l)->
      SVG.attr elm, "fill", "hsl(#{h*360}, #{s*100}%, #{l*100}%)"
      elm # Chainable
    
    createGradient: (name, vertical, stops...)->
      attrs = if vertical then { id: name, x2: 0, y2: 1 } else { id: name }
      gradient = SVG.create "linearGradient", defs, attrs
      createStops gradient, stops
      null # Not Chainable
    
    createRadialGradient: (name, stops...)->
      gradient = SVG.create "radialGradient", defs, id: name
      createStops gradient, stops
      null # Not Chainable
    
    createColorMatrix: (name, values)->
      filter = SVG.create "filter", defs, id: name
      attrs = { in: "SourceGraphic", type: "matrix", values: values }
      SVG.create "feColorMatrix", filter, attrs
      null # Not Chainable
  
  
  createStops = (gradient, stops)->
    stops = if stops[0] instanceof Array then stops[0] else stops
    for stop, i in stops
      attrs = if typeof stop is "string"
        { "stop-color": stop, offset: (100 * i/(stops.length-1)) + "%" }
      else
        { "stop-color": stop.color, offset: (100 * stop.offset) + "%" }
      SVG.create "stop", gradient, attrs
    null # Not Chainable
  
  
  makePrivateProps = (elm)->
    elm._SVG =
      _tx:0, _ty:0, _r:0, _cx:0, _cy:0, _sx:1, _sy:1
      _applyTransform: ()->
        SVG.attr elm, "transform", "translate(#{elm._SVG._tx},#{elm._SVG._ty}) rotate(#{elm._SVG._r},#{elm._SVG._cx},#{elm._SVG._cy}) scale(#{elm._SVG._sx},#{elm._SVG._sy})"
