Take ["GUI","KeyMe","Reaction","RAF","Resize","SVG","TRS","Tween"],
(      GUI , KeyMe , Reaction , RAF , Resize , SVG , TRS , Tween)->
  minVel = 0.1
  maxVel = xy: 10, z: 0.05 # xy polar, z cartesian
  minZoom = 0
  maxZoom = 3
  accel = xy: 0.7, z: 0.004 # xy polar, z cartesian
  decel = xy: 1.25, z: 1.001 # xy polar, z cartesian
  vel = a: 0, d: 0, z: 0 # xy polar (angle, displacement), z cartesian
  pos = x: 0, y: 0, z: 0 # x, y, z cartesian
  registrationOffset = x:0, y:0
  base = x: 0, y: 0, z: 0
  ms = null
  nav = null
  zoom = null
  initialSize = null
  alreadyRan = false
  
  Take "ScopeReady", ()->
    if msElm = document.querySelector "#mainStage"
      parent = msElm.parentNode
      ms = msElm._scope
      nav = TRS msElm
      mid = SVG.create "g", parent
      SVG.append mid, nav.parentNode
      zoom = TRS mid
      SVG.prepend parent, zoom.parentNode
      
      # Debug points
      # SVG.create "rect", nav, x:-4, y:-4, width:8, height:8, fill:"#F00"
      # SVG.create "rect", nav.parentNode, x:-3, y:-3, width:6, height:6, fill:"#FF0"
      # SVG.create "rect", zoom.parentNode, x:-2, y:-2, width:4, height:4, fill:"#F70"
      
      initialSize = msElm.getBoundingClientRect()
      registrationOffset.x = -ms.x + initialSize.left + initialSize.width/2
      registrationOffset.y = -ms.y + initialSize.top + initialSize.height/2
      TRS.abs nav, ox: registrationOffset.x, oy: registrationOffset.y
      
      Resize resize
      
      KeyMe "up", down: run
      KeyMe "down", down: run
      KeyMe "left", down: run
      KeyMe "right", down: run
      KeyMe "equals", down: run
      KeyMe "minus", down: run
      window.addEventListener "touchstart", touchStart
      window.addEventListener "dblclick", dblclick
      window.addEventListener "wheel", wheel
  
  resize = ()->
    width = window.innerWidth# - GUI.ControlPanel.width
    height = window.innerHeight - GUI.TopBar.height
    wFrac = width / initialSize.width
    hFrac = height / initialSize.height
    base.x = width/2
    base.y = GUI.TopBar.height + height/2
    base.z = .9 * Math.min wFrac, hFrac
    TRS.abs zoom, x: base.x, y: base.y, scale: base.z
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
    
    inputX = getAccel right, left
    inputY = getAccel down, up
    inputZ = getAccel minus, plus
    
    # Do z first, so we can scale xy based on z
    vel.z /= decel.z if inputZ is 0
    vel.z = Math.max -maxVel.z, Math.min maxVel.z, vel.z + accel.z * inputZ
    pos.z += vel.z
    pos.z = Math.min maxZoom, Math.max minZoom, pos.z
    
    vel.d /= decel.xy if inputX is 0 and inputY is 0
    vel.a = Math.atan2 inputY, inputX if inputY or inputX
    vel.d = Math.min maxVel.xy, vel.d + accel.xy * (Math.abs(inputX) + Math.abs(inputY))
    pos.x += Math.cos(vel.a) * vel.d / (1+pos.z)
    pos.y += Math.sin(vel.a) * vel.d / (1+pos.z)
    
    render()
  
  rerun = ()->
    alreadyRan = false
    p = KeyMe.pressing
    if vel.d > minVel or vel.z > minVel or p["left"] or p["right"] or p["up"] or p["down"] or p["equals"] or p["minus"]
      run()
    else
      vel.d = vel.z = 0
  
  render = ()->
    pos.z = Math.min maxZoom, Math.max minZoom, pos.z
    TRS.abs nav, x: pos.x, y: pos.y
    TRS.abs zoom, scale: base.z * Math.pow 2, pos.z

  
  getAccel = (neg, pos)->
    return -1 if neg and !pos
    return  1 if pos and !neg
    return  0
  
  
  wheel = (e)->
    return unless eventInside e.clientX, e.clientY
    e.preventDefault()
    if e.ctrlKey # Chrome, pinch-to-zoom
      pos.z -= e.deltaY / 100
    else if e.metaKey # Other browsers, meta+scroll zoom
      pos.z -= e.deltaY / 200
    else
      pos.x -= e.deltaX / (base.z * Math.pow 2, pos.z)
      pos.y -= e.deltaY / (base.z * Math.pow 2, pos.z)
      pos.z -= e.deltaZ
    RAF render, true
  
  
  touches = null
  
  touchStart = (e)->
    return unless eventInside e.touches[0].clientX, e.touches[0].clientY
    e.preventDefault()
    touches = cloneTouches e
    vel.d = vel.z = 0
    window.addEventListener "touchmove", touchMove
    window.addEventListener "touchend", touchEnd
    
    
  touchMove = (e)->
    e.preventDefault()
    if e.touches.length isnt touches.length
      # noop
    else if e.touches.length > 1
      a = distTouches touches
      b = distTouches e.touches
      pos.z += (b - a) / 200
      pos.z = Math.min maxZoom, Math.max minZoom, pos.z
    else
      pos.x += (e.touches[0].clientX - touches[0].clientX) / (base.z * Math.pow 2, pos.z)
      pos.y += (e.touches[0].clientY - touches[0].clientY) / (base.z * Math.pow 2, pos.z)
    touches = cloneTouches e
    RAF render, true
  
  touchEnd = (e)->
    if touches.length <= 1
      window.removeEventListener "touchmove", touchMove
      window.removeEventListener "touchend", touchEnd

  
  cloneTouches = (e)->
    for t in e.touches
      clientX: t.clientX
      clientY: t.clientY
  
  
  dblclick = (e)->
    if eventInside e.clientX, e.clientY
      e.preventDefault()
      to 0, 0, 0
  
  
  to = (x, y, z)->
    target =
      x: if x? then x else pos.x
      y: if y? then y else pos.y
      z: if z? then z else pos.z
    time = Math.sqrt(distTo pos, target) / 30
    if time > 0
      Tween on:pos, to:target, time: time, tick: render
  
  
  distTouches = (touches)->
    a = touches[0]
    b = touches[1]
    dx = a.clientX - b.clientX
    dy = a.clientY - b.clientY
    dist dx, dy
  
  distTo = (a, b)->
    dx = a.x - b.x
    dy = a.y - b.y
    dz = 200 * a.z - b.z
    dist dx, dy, dz
  
  dist = (x, y, z = 0)->
    Math.sqrt x*x + y*y + z*z
  
  
  eventInside = (x, y)->
    panelHidden = false # !Control.panelShowing # TODO
    insidePanel = x < window.innerWidth - GUI.ControlPanel.width
    insideTopBar = y > GUI.TopBar.height
    return insideTopBar and (panelHidden or insidePanel)
