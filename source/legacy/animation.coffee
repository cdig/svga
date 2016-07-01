Take "RAF", (RAF)->
  Make "Animation", Animation = (scope)->
    
    # Don't setup if the animation property is null
    return unless scope.animation?
    
    # We're about to overwrite the scope.animation property.
    # Save the existing function so we can refer to it later.
    # It must remain on the scope object, or else @foo won't work inside the function.
    scope._callback = scope.animation
    
    running = false
    restart = false
    dt = 0
    time = 0
    startTime = 0
    
    
    update = (t)->
      return unless running
      
      if restart
        restart = false
        startTime = t/1000
        time = 0
      
      else
        newTime = t/1000 - startTime
        dt = newTime - time
        time = newTime
        scope._callback dt, time
      
      RAF update if running
    
    
    # Overwrite the animation property with our fancy API
    scope.animation =
      
      start: ()->
        RAF update unless running
        running = true
        restart = true
      
      stop: ()->
        running = false
      
      toggle: ()->
        if running then @stop() else @start()
