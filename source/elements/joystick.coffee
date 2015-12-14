do ->
  Take ["Ease", "PointerInput", "Vector"], (Ease, PointerInput, Vector)->
    #child5 = knob
    #child4 = stem
    #child3 = top of the base
    #child2 = midde of the base
    # all values taken from the flash elements
    # scope.knob.child5.transform.y += (-37.7 - -14.8 - 7.2) (-30.1)
    # scope.knob.child5.transform.scaleY = 0.84 
    # scope.knob.child4.transform.y += (-9.05 - -1.35) (-7.1)
    # scope.knob.child3.transform.y += (-2.55 - 5.45) (-8)
    # scope.knob.child2.transform.y += (1.45 - 5.45 ) (-4)
    knobMaxY = -30.1
    knobMaxScale = 0.84
    stemMaxY = -7.1
    topMaxY = -8
    middleMaxY = -4
    
    Make "Joystick", joystick = (svgElement)->
      return scope = 
        movement: 0.0
        default: 0.0
        down: false
        mousePos: {x: 0, y: 0}
        moved: false
        callbacks: []    
        rangeMin: 0
        rangeMax: 1
        sticky: true
        
        setup: ()->
          scope.setTransforms()
          PointerInput.addDown(svgElement, scope.mouseDown)
          PointerInput.addMove(svgElement, scope.mouseMove)
          PointerInput.addMove(scope.root.getElement, scope.mouseMove)
          PointerInput.addUp(svgElement, scope.mouseUp)
          PointerInput.addUp(scope.root.getElement, scope.mouseUp)
        
        setDefault: (pos)->
          scope.default = Ease.linear(pos, scope.rangeMin, scope.rangeMax, 0, 1, true)
          scope.movement = scope.default
          scope.setTransforms()

        setTransforms: ()->
          scope.knob.child5.transform.y = scope.movement *  knobMaxY
          scope.knob.child5.transform.scaleY = (1.0 - scope.movement) + scope.movement * knobMaxScale
          scope.knob.child4.transform.y = scope.movement * stemMaxY
          scope.knob.child3.transform.y = scope.movement * topMaxY
          scope.knob.child2.transform.y = scope.movement * middleMaxY

        setRange: (rMin, rMax)->
          scope.rangeMin = rMin
          scope.rangeMax = rMax

        setSticky: (sticky)->
          scope.sticky = sticky

        mouseClick: (e)->
          scope.movement = scope.default
          scope.setTransforms()

        mouseDown: (e)->
          scope.down = true
          scope.mousePos = Vector.fromEventClient(e)


        mouseMove: (e)->
          if scope.down 
            scope.moved = true
            newPos = Vector.fromEventClient(e)
            distance = (newPos.y - scope.mousePos.y)/100
            scope.mousePos = newPos
            scope.movement -= distance
            if scope.movement > 1.0
              scope.movement = 1.0
            else if scope.movement < 0.0
              scope.movement = 0.0
            scope.setTransforms()
            for callback in scope.callbacks
              callback Ease.linear(scope.movement, 0, 1, scope.rangeMin, scope.rangeMax)

        mouseUp: ()->
          if not scope.down
            return
          scope.down = false
          if not scope.moved or not scope.sticky
            scope.movement = scope.default
            scope.setTransforms()
            for callback in scope.callbacks
              callback Ease.linear(scope.movement, 0, 1, scope.rangeMin, scope.rangeMax)
          scope.moved = false
        setCallback: (callback)->
          scope.callbacks.push callback