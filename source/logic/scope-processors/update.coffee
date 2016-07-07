# scope.update
# An every-frame update function that can be turned on and off by the content creator.

Take ["ScopeBuilder", "Tick"], (ScopeBuilder, Tick)->
  ScopeBuilder.process (scope)->
    return unless scope.update?
    
    running = false
    startTime = null
    
    # Replace the actual scope update function with a warning
    update = scope.update
    scope.update = ()-> throw "@update() is called by the system. Please don't call it yourself."
    
    Tick (time, dt)->
      return unless running
      update.call scope, dt, time - startTime # Yes, the dt & time arguments are switched — legacy reasons :(
    
    scope.update.start = ()->
      startTime ?= (performance?.now() or 0)/1000
      running = true
    
    scope.update.stop = ()->
      running = false
    
    scope.update.toggle = ()->
      if running then scope.update.stop() else scope.update.start()

    scope.update.restart = ()->
      startTime = null
