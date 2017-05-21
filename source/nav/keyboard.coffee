Take ["KeyMe", "Mode", "Nav", "Tick"], (KeyMe, Mode, Nav, Tick)->
  return unless Mode.nav
  
  decel = 1.25
  maxVel = xy: 10, z: 0.05 # xy polar, z cartesian
  accel = xy: 0.7, z: 0.004 # xy polar, z cartesian
  vel = a: 0, d: 0, z: 0 # xy polar (angle, displacement), z cartesian
  
  Tick ()->
    left = KeyMe.pressing["left"]
    right = KeyMe.pressing["right"]
    up = KeyMe.pressing["up"]
    down = KeyMe.pressing["down"]
    plus = KeyMe.pressing["equals"]
    minus = KeyMe.pressing["minus"]
    
    inputX = getAccel left, right
    inputY = getAccel up, down
    inputZ = getAccel plus, minus
    
    # Do z first, so we can scale xy based on z
    vel.z /= decel if inputZ is 0
    vel.z = Math.max -maxVel.z, Math.min maxVel.z, vel.z + accel.z * inputZ
    
    vel.d /= decel if inputX is 0 and inputY is 0
    vel.a = Math.atan2 inputY, inputX if inputY or inputX
    vel.d = Math.min maxVel.xy, vel.d + accel.xy * (Math.abs(inputX) + Math.abs(inputY))

    return unless Math.abs(vel.d) > 0.01 or Math.abs(vel.z) > 0.01
    
    Nav.by
      x: Math.cos(vel.a) * vel.d
      y: Math.sin(vel.a) * vel.d
      z: vel.z

  
  getAccel = (pos, neg)->
    return  1 if pos and !neg
    return -1 if neg and !pos
    return  0
  
