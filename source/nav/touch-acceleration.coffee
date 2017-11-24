Take ["Nav", "Tick"], (Nav, Tick)->
  
  vel = x: 0, y: 0
  running = false
  
  Tick (t, dt)->
    return unless running
    if Math.abs(vel.x) > 0.1 or Math.abs(vel.y) > 0.1
      Nav.by vel
      vel.x /= 1.15
      vel.y /= 1.15
    else
      running = false
  
  Make "TouchAcceleration",
    move: (accel)->
      vel.x = accel.x
      vel.y = accel.y
      Nav.by vel
      running = false
    
    up: ()->
      if Math.abs(vel.x) > 2 or Math.abs(vel.y) > 2
        running = true
