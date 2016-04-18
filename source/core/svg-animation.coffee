Make "SVGAnimation", SVGAnimation = (callback)->
  return scope =
    running: false
    restart: false
    time: 0
    startTime: 0
    dT: 0

    runAnimation: (currTime)->
      if not scope.running
        return
      if scope.restart
        scope.startTime = currTime
        scope.time =  0
        scope.restart = false
      else
        newTime = currTime - scope.startTime
        dT = (newTime - scope.time)/1000
        scope.time = newTime
        callback(dT, scope.time)



      if scope.running
        requestAnimationFrame(scope.runAnimation)



    start: ()->
      if scope.running
        scope.restart = true
        return

      scope.running = true


      startAnimation = (currTime)->
        scope.startTime = currTime
        scope.time = 0
        requestAnimationFrame(scope.runAnimation)

      requestAnimationFrame(startAnimation)

    stop: ()->
      scope.running = false


