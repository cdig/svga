Take ["Pressure", "SVG"], (Pressure , SVG)->
  Make "FlowArrows:Containerize", (parentElm, setupFn)->
    
    direction = 1
    flow = 1
    pressure = null
    scale = 1
    active = true
    enabled = true
    visible = true
    scope =
      element: SVG.create "g", parentElm
      reverse: ()->
        direction *= -1
      update: (parentFlow, parentScale)->
        if active
          f = flow * direction * parentFlow
          s = scale * parentScale
          for child in children
            child.update f, s
    children = setupFn scope
    
    
    updateActive = ()->
      active = enabled and visible and flow isnt 0
      SVG.styles scope.element, display: if active then null else "none"
    
    
    # This is used by FlowArrows when toggling
    Object.defineProperty scope, 'enabled',
      set: (val)->
        updateActive visible = val if visible isnt val
    
    Object.defineProperty scope, 'flow',
      get: ()-> flow
      set: (val)->
        updateActive flow = val if flow isnt val
    
    Object.defineProperty scope, 'pressure',
      get: ()-> pressure
      set: (val)->
        if pressure isnt val
          pressure = val
          color = Pressure val
          SVG.attrs scope.element, fill: color, stroke: color
    
    Object.defineProperty scope, 'scale',
      get: ()-> scale
      set: (val)->
        scale = val if scale isnt val

    Object.defineProperty scope, 'visible',
      get: ()-> visible
      set: (val)->
        updateActive visible = val if visible isnt val
    
    return scope
