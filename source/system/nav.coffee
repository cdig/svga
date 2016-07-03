Take ["Control","Reaction","Resize","root","SVG","TopBar","TRS"],
(      Control , Reaction , Resize , root , SVG , TopBar , TRS)->
  maxVel = 10
  accel = x: 1, y: 1, z: 1
  vel = x: 0, y: 0, z: 0
  pos = x: 0, y: 0, z: 0
  ms = null
  nav = null
  initialSize = null
  
  Reaction "ScopeReady", ()->
    if ms = root.mainStage
      nav = TRS ms.element
      msx = ms.x
      msy = ms.y
      initialSize = ms.element.getBoundingClientRect()
      TRS.abs nav, ox: -msx+initialSize.left+initialSize.width/2, oy: -msy+initialSize.top+initialSize.height/2, now:true
      TRS.abs nav, x:window.innerWidth/2, y:window.innerHeight/2, now: true
      Resize resize
    Make "NavReady"

  resize = ()->
    width = window.innerWidth - Control.panelWidth()
    height = window.innerHeight - TopBar.height
    wFrac = width / initialSize.width
    hFrac = height / initialSize.height
    frac = .9 * Math.min wFrac, hFrac
    TRS.abs nav, x: width/2, y: TopBar.height + height/2, sx: frac, sy: frac
  
