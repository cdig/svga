# scope.animate
# An every-frame update function that only runs in animate mode.

Take ["Reaction", "ScopeBuilder", "Tick"], (Reaction, ScopeBuilder, Tick)->
  ScopeBuilder.process (scope)->
    return unless scope.animate?
    
    running = false
    startTime = 0
    
    Tick (time, dt)->
      return unless running
      scope.animate.call scope, dt, time - startTime # Yes, the dt & time arguments are switched — legacy reasons :(
    
    Reaction "Schematic:Hide", ()->
      startTime = (performance?.now() or 0)/1000
      running = true
    
    Reaction "Schematic:Show", ()->
      running = false
