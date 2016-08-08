# scope.tick
# An every-frame update function that can be turned on and off by the content creator.

Take ["Registry", "Tick"], (Registry, Tick)->
  Registry.add "ScopeProcessor", (scope)->
    return unless scope.tick?
    
    running = true
    startTime = null
    
    # Replace the actual scope tick function with a warning
    tick = scope.tick
    scope.tick = ()-> throw "@tick() is called by the system. Please don't call it yourself."
    
    Tick (time, dt)->
      return unless running
      startTime ?= time
      tick.call scope, time - startTime, dt
    
    scope.tick.start = ()->
      running = true
    
    scope.tick.stop = ()->
      running = false
    
    scope.tick.toggle = ()->
      if running then scope.tick.stop() else scope.tick.start()
    
    scope.tick.restart = ()->
      startTime = null
