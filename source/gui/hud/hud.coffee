Take ["Mode", "ParentElement", "Tick", "SVGReady"], (Mode, ParentElement, Tick)->
  return unless Mode.dev

  rate = .1 # Update every n seconds
  elapsed = rate # Run the first update immediately
  needsUpdate = true
  
  colors = {}
  values = {}
  
  elm = document.createElement "div"
  elm.setAttribute "svga-hud", "true"
  
  if not Mode.embed
    document.body.insertBefore elm, document.body.firstChild
  else
    # If the SVGA is removed and re-added, it creates duplicate HUD elements.
    # So if there's an existing element, we should just use it.
    prev = ParentElement.previousSibling
    if prev?.hasAttribute? "svga-hud"
      elm = prev
    else
      ParentElement.parentNode?.insertBefore elm, ParentElement
  
  Tick (time, dt)->
    elapsed += dt
    if elapsed >= rate
      elapsed -= rate
      if needsUpdate
        needsUpdate = false
        html = ""
        for k, v of values
          html += "<div style='color:#{colors[k]}'>#{k}: #{v}</div>"
        elm.innerHTML = html
  
  Make "HUD", HUD = (k, v, c = "#0008")->
    
    # Allow passing an object of k-v pairs, with the 2nd arg as the optional color
    if typeof k is "object"
      for _k, _v of k
        HUD _k, _v, v
    
    else
      if values[k] isnt v or not values[k]?
        values[k] = v
        colors[k] = c
        needsUpdate = true

    undefined
