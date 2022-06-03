Take ["Mode", "Tick", "SVG", "SVGReady"], (Mode, Tick, SVG)->

  if not Mode.dev
    Make "HUD", ()-> # Noop
    return

  rate = 1/30 # Update every nth of a second
  elapsed = rate # Run the first update immediately
  needsUpdate = true

  colors = {}
  values = {}

  elm = document.createElement "div"
  elm.setAttribute "svga-hud", "true"
  SVG.svg.parentElement.insertBefore elm, SVG.svg

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

  Make "HUD", HUD = (k, v, c = "#000")->

    # Allow passing an object of k-v pairs, with the 2nd arg as the optional color
    if typeof k is "object"
      for _k, _v of k
        HUD _k, _v, v

    # Pretty-print nested objects (and avoid infinite loops if there's a reference cycle)
    else if typeof v is "object" and not v._hud_visited
      v._hud_visited = true
      for _k, _v of v when _k isnt "_hud_visited"
        HUD "#{k}.#{_k}", _v, v
      v._hud_visited = false

    else
      if values[k] isnt v or not values[k]?
        values[k] = v
        colors[k] = c
        needsUpdate = true

    return v # Pass-through whenever possible
