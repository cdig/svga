Take "RequestDeferredRender", (RequestDeferredRender)->
  Make "SVGTransform", SVGTransform = (svgElement)->
    currentTransformString = null
    newTransformString = null
    didRequest = false
    
    scope =
        angleVal: 0
        xVal: 0
        yVal: 0
        cxVal: 0
        cyVal: 0
        scaleVal: 1
        scaleXVal: 1
        scaleYVal: 1
        turnsVal: 0
        
        # Do not ever set these properties
        scaleString: ""
        translateString: ""
        rotationString: ""
        baseTransform: svgElement.getAttribute("transform")

        setup: ()->
          Object.defineProperty scope, 'x',
            get: ()-> scope.xVal
            set: (val)->
              scope.xVal = val
              scope.translate(val, scope.y)

          Object.defineProperty scope, 'y',
            get: ()-> scope.yVal
            set: (val)->
              scope.yVal = val
              scope.translate(scope.x, val)
          
          Object.defineProperty scope, 'cx',
            get: ()-> scope.cxVal
            set: (val)->
              scope.cxVal = val
              scope.rotate(scope.angleVal, scope.cxVal, scope.cyVal)
          
          Object.defineProperty scope, 'cy',
            get: ()-> scope.cyVal
            set: (val)->
              scope.cyVal = val
              scope.rotate(scope.angleVal, scope.cxVal, scope.cyVal)
        
          Object.defineProperty scope, 'turns',
            get: ()-> scope.turnsVal
            set: (val)->
              scope.turnsVal = val
              scope.angleVal = scope.turnsVal * 360
              scope.rotate(scope.angleVal, scope.cxVal, scope.cyVal)
                
          Object.defineProperty scope, 'angle',
            get: ()-> scope.angleVal
            set: (val)->
              scope.angleVal = val
              scope.turnsVal = scope.angleVal / 360
              scope.rotate(scope.angleVal, scope.cxVal, scope.cyVal)
              
          Object.defineProperty scope, 'scale',
            get: ()-> scope.scaleVal
            set: (val)->
              scope.scaleVal = val
              scope.scaling(val)

          Object.defineProperty scope, 'scaleX',
            get: ()-> scope.scaleXVal
            set: (val)->
              scope.scaleXVal = val
              scope.scaling(scope.scaleXVal, scope.scaleYVal)
          
          Object.defineProperty scope, 'scaleY',
            get: ()-> scope.scaleYVal
            set: (val)->
              scope.scaleYVal = val
              scope.scaling(scope.scaleXVal, scope.scaleYVal)

        # Private Functions
        
        rotate: (angle, cx, cy)->
          scope.rotationString = "rotate(#{angle}, #{cx}, #{cy})"
          scope.setTransform()

        translate: (x, y)->
          scope.translateString = "translate(#{x}, #{y})"
          scope.setTransform()

        scaling: (scaleX, scaleY=scaleX)->
          scope.scaleString = "scale(#{scaleX}, #{scaleY})"
          scope.setTransform()

        setBaseTransform: ()->
          scope.baseTransform = svgElement.getAttribute("transform")
        
        setBaseIdentity: ()->
          scope.baseTransform = "matrix(1,0,0,1,0,0)"

        setTransform: ()->
          newTransform = "#{scope.baseTransform} #{scope.rotationString} #{scope.scaleString} #{scope.translateString}"
          svgElement.setAttribute('transform', newTransform)
        
        setTransform: ()->
          newTransformString = "#{scope.baseTransform} #{scope.rotationString} #{scope.scaleString} #{scope.translateString}"
          return if didRequest # Don't touch the DOM more than once per frame
          didRequest = true
          RequestDeferredRender scope.applyTransform
        
        applyTransform: ()->
          return if currentTransformString is newTransformString # Don't update unless the value is changing
          currentTransformString = newTransformString
          didRequest = false
          svgElement.setAttribute "transform", currentTransformString
