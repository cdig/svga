Take "RequestDeferredRender", (RequestDeferredRender)->
  Make "SVGTransform", SVGTransform = (svgElement)->
    baseTransform = svgElement.getAttribute "transform"
    currentTransformString = null
    newTransformString = null
    translateString = ""
    rotationString = ""
    scaleString = ""
    
    xVal = 0
    yVal = 0
    cxVal = 0
    cyVal = 0
    angleVal = 0
    scaleVal = 1
    scaleXVal = 1
    scaleYVal = 1
    
    scope = {}
    
    
    # LEGACY
    scope.setBaseIdentity = ()-> baseTransform = "matrix(1,0,0,1,0,0)"
    scope.setBaseTransform = ()-> baseTransform = svgElement.getAttribute("transform")
    
    
    rotate = (angle, cx, cy)->
      rotationString = "rotate(#{angle}, #{cx}, #{cy})"
      setTransform()

    translate = (x, y)->
      translateString = "translate(#{x}, #{y})"
      setTransform()

    scaling = (scaleX, scaleY=scaleX)->
      scaleString = "scale(#{scaleX}, #{scaleY})"
      setTransform()

    setTransform = ()->
      newTransformString = "#{baseTransform} #{rotationString} #{scaleString} #{translateString}"
      RequestDeferredRender applyTransform, true
    
    applyTransform = ()->
      return if currentTransformString is newTransformString # Don't update unless the value is changing
      currentTransformString = newTransformString
      svgElement.setAttribute "transform", currentTransformString
    
    
    Object.defineProperty scope, 'x',
      get: ()-> xVal
      set: (val)-> translate xVal = val, yVal

    Object.defineProperty scope, 'y',
      get: ()-> yVal
      set: (val)-> translate xVal, yVal = val
    
    Object.defineProperty scope, 'cx',
      get: ()-> cxVal
      set: (val)-> rotate angleVal, cxVal = val, cyVal
    
    Object.defineProperty scope, 'cy',
      get: ()-> cyVal
      set: (val)-> rotate angleVal, cxVal, cyVal = val
    
    Object.defineProperty scope, 'angle',
      get: ()-> angleVal
      set: (val)-> rotate angleVal = val, cxVal, cyVal
    
    Object.defineProperty scope, 'turns',
      get: ()-> scope.angle / 360
      set: (val)-> scope.angle = val * 360
    
    Object.defineProperty scope, 'scale',
      get: ()-> scaleVal
      set: (val)-> scaling scaleVal = val

    Object.defineProperty scope, 'scaleX',
      get: ()-> scaleXVal
      set: (val)-> scaling scaleXVal = val, scaleYVal
    
    Object.defineProperty scope, 'scaleY',
      get: ()-> scaleYVal
      set: (val)-> scaling scaleXVal, scaleYVal = val

      
    return scope
