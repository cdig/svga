Take ["RAF", "DOMContentLoaded"], (RAF)->
  Make "Transform", Transform = (scope)->
    element = scope.element
    transformBaseVal = element.transform.baseVal
    
    transform = document.rootElement.createSVGTransform()
    matrix = document.rootElement.createSVGMatrix()
    x = 0
    y = 0
    rotation = 0
    scaleX = 1
    scaleY = 1
    # skewX = 0
    # skewY = 0
    
    
    # Check that we aren't about to clobber anything
    for prop in ["x", "y", "rotation", "scale", "scaleX", "scaleY"] #, "skewX", "skewY"]
      if scope[prop]?
        console.log element
        throw "^ Transform will clobber scope.#{prop} on this element. Please find a different name for your child/property \"#{prop}\"."
    
    
    # Extract the existing transform value from the element
    if transformBaseVal.numberOfItems is 1
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
    else if transformBaseVal.numberOfItems > 1
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
    
    
    # Not sure if we want to implement these
    #
    # Object.defineProperty scope, 'skewX',
    #   get: ()-> skewX
    #   set: (val)->
    #     skewX = val
    #     RAF applyTransform, true, 1
    #
    # Object.defineProperty scope, 'skewY',
    #   get: ()-> skewY
    #   set: (val)->
    #     rotation = val
    #     RAF applyTransform, true, 1
    
    
    # OBSOLETE ####################################################################################
    
    Object.defineProperty scope, 'cx',
      get: ()-> throw "cx has been removed from the SVGA Transform system."
      set: ()-> throw "cx has been removed from the SVGA Transform system."
    
    Object.defineProperty scope, 'cy',
      get: ()-> throw "cy has been removed from the SVGA Transform system."
      set: ()-> throw "cy has been removed from the SVGA Transform system."
    
    Object.defineProperty scope, 'angle',
      get: ()-> throw "angle has been removed from the SVGA Transform system. Please use scope.rotation instead."
      set: ()-> throw "angle has been removed from the SVGA Transform system. Please use scope.rotation instead."
    
    Object.defineProperty scope, 'turns',
      get: ()-> throw "turns has been removed from the SVGA Transform system. Please use scope.rotation instead."
      set: ()-> throw "turns has been removed from the SVGA Transform system. Please use scope.rotation instead."

    Object.defineProperty scope, "transform",
      get: ()-> throw "scope.transform has been removed. You can just delete the .transform and things should work."
    
    
    # LEGACY
    # api.setBaseIdentity = ()-> baseTransform = "matrix(1,0,0,1,0,0)"
    # api.setBaseTransform = ()-> baseTransform = element.getAttribute("transform")
