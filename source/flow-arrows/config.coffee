do ()->
  Make "FlowArrows:Config", Config =
    SCALE: 1 # Visible size of arrows is multiplied by this value — it's not factored in to any of the other size/distance/speed values
    SPACING: 600 # APPROXIMATELY how far apart should arrows be spaced? (+/-)50%
    FADE_LENGTH: 50 # Over how great a distance do Arrows fade in/out?
    MIN_SEGMENT_LENGTH: 200 # How long must a segment be before we put arrows on it?
    SPEED: 200 # The speed Arrows move per second when flow is 1
    MIN_EDGE_LENGTH: 8 # How long must an edge be to survive being culled?
    CONNECTED_DISTANCE: 1 # How close must two physically-disconnected points be to be treated as part of the same line?
    
    wrap: (obj)->
      defineProp obj, k for k of Config when k isnt "wrap"
      obj # Composable
  
  defineProp = (obj, k)->
    Object.defineProperty obj, k,
      get: ()-> Config[k]
      set: (v)-> Config[k] = v
