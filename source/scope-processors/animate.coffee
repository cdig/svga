# scope.animate
# An every-frame update function that only runs in animate mode.

Take ["Reaction", "Registry", "Tick"], (Reaction, Registry, Tick)->
  Registry.add "ScopeProcessor", (scope)->
    return unless scope.animate?
    
    running = false
    startTime = 0
    
    # Replace the actual scope animate function with a warning
    animate = scope.animate
    scope.animate = ()-> throw "@animate() is called by the system. Please don't call it yourself."
    
    Tick (time, dt)->
      return unless running
      animate.call scope, dt, time - startTime # Yes, the dt & time arguments are switched — legacy reasons :(
    
    Reaction "Schematic:Hide", ()->
      startTime = (performance?.now() or 0)/1000
      running = true
    
    Reaction "Schematic:Show", ()->
      running = false
