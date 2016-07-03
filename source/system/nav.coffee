Take ["Control","KeyMe","Reaction","RAF","Resize","root","SVG","TopBar","TRS"],
(      Control , KeyMe , Reaction , RAF , Resize , root , SVG , TopBar , TRS)->
  maxVel = 10
  input = x: 0, y: 0, z: 0
  vel = x: 0, y: 0, z: 0
  pos = x: 0, y: 0, z: 0
  ms = null
  nav = null
  initialSize = null
  alreadyRan = false
  
  Reaction "ScopeReady", ()->
    if ms = root.mainStage
      nav = TRS ms.element
      msx = ms.x
      msy = ms.y
      initialSize = ms.element.getBoundingClientRect()
      TRS.abs nav, ox: -msx+initialSize.left+initialSize.width/2, oy: -msy+initialSize.top+initialSize.height/2, now:true
      TRS.abs nav, x:window.innerWidth/2, y:window.innerHeight/2, now: true
      Resize resize
      KeyMe "up", down: run
      KeyMe "down", down: run
      KeyMe "left", down: run
      KeyMe "right", down: run
      KeyMe "plus", down: run
      KeyMe "minus", down: run
      
    Make "NavReady"
  
  resize = ()->
    width = window.innerWidth - Control.panelWidth()
    height = window.innerHeight - TopBar.height
    wFrac = width / initialSize.width
    hFrac = height / initialSize.height
    frac = .9 * Math.min wFrac, hFrac
    TRS.abs nav, x: width/2, y: TopBar.height + height/2, sx: frac, sy: frac
  
  
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
    plus = KeyMe.pressing["plus"]
    
    input.x = getAccel left, right
    input.y = getAccel up, down
    input.z = getAccel minus, plus
    
    console.log input
  
  rerun = ()->
    alreadyRan = false
    p = KeyMe.pressing
    run() if p["left"] or p["right"] or p["up"] or p["down"] or p["plus"] or p["minus"]
  
  
  getAccel = (neg, pos)->
    return -1 if neg and !pos
    return  1 if pos and !neg
    return  0
  
