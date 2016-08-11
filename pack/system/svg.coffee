# These are Ivan's SVG tools. They're private APIs, part of the implementation of SVGA.
# They're not to be used by content, since they might endure breaking changes at any time.
# They may be used by Controls, since those are a more advanced feature of SVGA.

do ()->
  
  root = document.rootElement
  defs = root.querySelector "defs"
  
  svgNS = "http://www.w3.org/2000/svg"
  xlinkNS = "http://www.w3.org/1999/xlink"
  
  # This is used to distinguish props from attrs, so we can set both with SVG.attr
  propNames =
    textContent: true
    # additional prop names will be listed here as needed
  
  # This is used to cache normalized keys, and to provide defaults for keys that shouldn't be normalized
  attrNames =
    viewBox: "viewBox"
    # additional attr names will be listed here as needed
  
  # We want to wait until SVGReady fires before we change the structure of the DOM.
  # However, we can't just Take "SVGReady" at the top, because other systems want
  # to use us in safe, non-structural ways before SVGReady has fired. So we do this:
  SVGReady = false
  CheckSVGReady = ()-> SVGReady or (SVGReady = Take "SVGReady")
  
  
  Make "SVG", SVG =
    root: root
    defs: defs
    
    create: (type, parent, attrs)->
      elm = document.createElementNS svgNS, type
      SVG.attrs elm, attrs if attrs?
      SVG.append parent, elm if parent?
      elm # Composable
    
    clone: (source, parent, attrs)->
      throw "Clone source is undefined in SVG.clone(source, parent, attrs)" unless source?
      throw "SVG.clone() called before SVGReady" unless CheckSVGReady()
      elm = document.createElementNS svgNS, "g"
      SVG.attr elm, attr.name, attr.value for attr in source.attributes
      SVG.attrs elm, id: null
      SVG.attrs elm, attrs if attrs?
      SVG.append elm, child.cloneNode true for child in source.childNodes
      SVG.append parent, elm if parent?
      elm # Composable
    
    append: (parent, child)->
      throw "SVG.append() called before SVGReady" unless CheckSVGReady()
      parent.appendChild child
      child # Composable
    
    prepend: (parent, child)->
      throw "SVG.prepend() called before SVGReady" unless CheckSVGReady()
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
      return elm._SVG_attr[k] ?= elm.getAttribute(k) if v is undefined # Read
      return v if elm._SVG_attr[k] is v # cache hit — bail
      elm._SVG_attr[k] = v # update cache
      return elm[k] = v if propNames[k]? # set DOM property
      ns = if k is "xlink:href" then xlinkNS else null
      k = attrNames[k] ?= k.replace(/([A-Z])/g,"-$1").toLowerCase() # Normalize camelCase into kebab-case
      if v?
        elm.setAttributeNS ns, k, v # set DOM attribute
      else # v is explicitly set to null (not undefined)
        elm.removeAttributeNS ns, k # remove DOM attribute
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
