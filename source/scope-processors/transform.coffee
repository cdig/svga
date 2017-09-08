Take ["RAF", "Registry", "ScopeCheck", "SVG"], (RAF, Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "x", "y", "rotation", "scale", "scaleX", "scaleY"
    
    element = scope.element
    transformBaseVal = element.transform?.baseVal
    
    transform = SVG.svg.createSVGTransform()
    matrix = SVG.svg.createSVGMatrix()
    x = 0
    y = 0
    rotation = 0
    scaleX = 1
    scaleY = 1
    
    # Extract the existing transform value from the element
    if transformBaseVal?.numberOfItems is 1
      t = transformBaseVal.getItem 0
      switch t.type
        when SVGTransform.SVG_TRANSFORM_MATRIX
          x = t.matrix.e
          y = t.matrix.f
          rotation = 180/Math.PI * Math.atan2 t.matrix.b, t.matrix.a
          denom = Math.pow(t.matrix.a, 2) + Math.pow t.matrix.c, 2
          scaleX = Math.sqrt denom
          scaleY = (t.matrix.a * t.matrix.d - t.matrix.b * t.matrix.c) / scaleX
          # skewX = 180/Math.PI * Math.atan2 t.matrix.a * t.matrix.b + t.matrix.c * t.matrix.d, denom
        else
          throw new Error "^ Transform encountered an SVG element with a non-matrix transform"
    else if transformBaseVal?.numberOfItems > 1
      console.log element
      throw new Error "^ Transform encountered an SVG element with more than one transform"
    
    
    applyTransform = ()->
      # TODO: introduce a guard here to check if the value has changed
      matrix.a = scaleX
      matrix.d = scaleY
      matrix.e = x
      matrix.f = y
      transform.setMatrix matrix.rotate rotation
      element.transform.baseVal.initialize transform
    
    
    Object.defineProperty scope, 'x',
      get: ()-> x
      set: (val)->
        if x isnt val
          x = val
          RAF applyTransform, true, 1
    
    Object.defineProperty scope, 'y',
      get: ()-> y
      set: (val)->
        if y isnt val
          y = val
          RAF applyTransform, true, 1
    
    Object.defineProperty scope, 'rotation',
      get: ()-> rotation
      set: (val)->
        if rotation isnt val
          rotation = val
          RAF applyTransform, true, 1
    
    Object.defineProperty scope, 'scale',
      get: ()-> (scaleX + scaleY)/2
      set: (val)->
        if scaleX isnt val or scaleY isnt val
          scaleX = scaleY = val
          RAF applyTransform, true, 1
    
    Object.defineProperty scope, 'scaleX',
      get: ()-> scaleX
      set: (val)->
        if scaleX isnt val
          scaleX = val
          RAF applyTransform, true, 1
    
    Object.defineProperty scope, 'scaleY',
      get: ()-> scaleY
      set: (val)->
        if scaleY isnt val
          scaleY = val
          RAF applyTransform, true, 1
