Take ["Control","KeyMe","Reaction","RAF","Resize","root","SVG","TopBar","TRS"],
(      Control , KeyMe , Reaction , RAF , Resize , root , SVG , TopBar , TRS)->
  accel = xy: 5, z: 0.01 # xy polar, z cartesian
  decel = xy: 1.25, z: 1.25 # xy polar, z cartesian
  maxVel = xy: 10, z: 0.2 # xy polar, z cartesian
  minVel = 0.1
  minBounds = z: 0
  maxBounds = z: 3
  vel = a: 0, d: 0, z: 0 # xy polar (angle, dist), z cartesian
  pos = x: 0, y: 0, z: 0 # x, y, z cartesian
  registrationOffset = x:0, y:0
  base = x: 0, y: 0, z: 0
  ms = null
  nav = null
  zoom = null
  initialSize = null
  alreadyRan = false
  
  Reaction "ScopeReady", ()->
    if ms = root.mainStage
      nav = TRS ms.element
      mid = SVG.create "g", SVG.root
      SVG.append mid, nav.parentNode
      zoom = TRS mid
      SVG.prepend SVG.root, zoom.parentNode
      
      # Debug points
      SVG.create "rect", nav, x:-4, y:-4, width:8, height:8, fill:"#F00"
      SVG.create "rect", nav.parentNode, x:-3, y:-3, width:6, height:6, fill:"#FF0"
      SVG.create "rect", zoom.parentNode, x:-2, y:-2, width:4, height:4, fill:"#F70"
      
      initialSize = ms.element.getBoundingClientRect()
      registrationOffset.x = -ms.x + initialSize.left + initialSize.width/2
      registrationOffset.y = -ms.y + initialSize.top + initialSize.height/2
      TRS.abs nav, ox: registrationOffset.x, oy: registrationOffset.y, now:true
      
      Resize resize
      
      KeyMe "up", down: run
      KeyMe "down", down: run
      KeyMe "left", down: run
      KeyMe "right", down: run
      KeyMe "equals", down: run
      KeyMe "minus", down: run
      
    Make "NavReady"
  
  resize = ()->
    width = window.innerWidth - Control.panelWidth()
    height = window.innerHeight - TopBar.height
    wFrac = width / initialSize.width
    hFrac = height / initialSize.height
    base.x = width/2
    base.y = TopBar.height + height/2
    base.z = .9 * Math.min wFrac, hFrac
    TRS.abs zoom, x: base.x, y: base.y, scale: base.z, now:true
    run()
  
  
  run = ()->
    # This function executes immediately upon keypress, so we need to avoid running multiple times per frame
    return if alreadyRan
    alreadyRan = true
    RAF rerun
    
    left = KeyMe.pressing["left"]
    right = KeyMe.pressing["right"]
    up = KeyMe.pressing["up"]
    down = KeyMe.pressing["down"]
    minus = KeyMe.pressing["minus"]
    plus = KeyMe.pressing["equals"]
    
    # input = x: 0, y: 0, z: 0 # x, y, z cartesian
    # accel = xy: 0.1, z: 0.1 # xy polar, z cartesian
    # vel = a: 0, d: 0, z: 0 # xy polar
    # pos = x: 0, y: 0, z: 0 # x, y, z cartesian
    
    inputX = getAccel right, left
    inputY = getAccel down, up
    inputZ = getAccel minus, plus
    
    vel.d /= decel.xy if inputX is 0 and inputY is 0
    vel.z /= decel.z
    
    vel.a = Math.atan2 inputY, inputX if inputY or inputX
    vel.d = Math.min maxVel.xy, vel.d + accel.xy * (Math.abs(inputX) + Math.abs(inputY))
    vel.z = Math.min maxVel.z, vel.z + accel.z * inputZ
    
    pos.x += Math.cos(vel.a) * vel.d
    pos.y += Math.sin(vel.a) * vel.d
    pos.z += vel.z
    
    pos.z = Math.min maxBounds.z, Math.max minBounds.z, pos.z
    
    TRS.abs nav, x: pos.x, y: pos.y
    TRS.abs zoom, scale: base.z * Math.pow 2, pos.z
    
  rerun = ()->
    alreadyRan = false
    p = KeyMe.pressing
    if vel.d > minVel or vel.z > minVel or p["left"] or p["right"] or p["up"] or p["down"] or p["equals"] or p["minus"]
      run()
    else
      vel.d = vel.z = 0
  
  
  getAccel = (neg, pos)->
    return -1 if neg and !pos
    return  1 if pos and !neg
    return  0
  
