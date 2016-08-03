Take ["GUI", "RAF", "Resize", "SVG", "Tween", "ScopeReady"], (GUI, RAF, Resize, SVG, Tween)->
  pos = x: 0, y: 0, z: 0
  center = x: 0, y: 0, z: 1
  xLimit = {}
  yLimit = {}
  zLimit = min: 0, max: 3
  scaleStartPosZ = 0
  
  zoom = SVG.create "g", null, xZoom:""
  nav = SVG.create "g", zoom, xNav:""
  root = document.getElementById "root" # This is the "root" symbol, not to be confused with the <svg> aka rootElement
  SVG.prepend document.rootElement, zoom
  SVG.append nav, root
  
  # Debug points
  # SVG.create "rect", nav, x:-8, y:-8, width:16, height:16, fill:"#F00"
  # SVG.create "rect", zoom, x:-6, y:-6, width:12, height:12, fill:"#F0F"
  
  initialSize = root.getBoundingClientRect()
  return unless initialSize.width > 0 and initialSize.height > 0 # This avoids a divide by zero error when the SVG is empty
  ox = root._scope.x - initialSize.left - initialSize.width/2
  oy = root._scope.y - initialSize.top - initialSize.height/2
  xLimit.max = initialSize.width/2
  yLimit.max = initialSize.height/2
  xLimit.min = -xLimit.max
  yLimit.min = -yLimit.max
  
  Resize ()->
    width = window.innerWidth - GUI.ControlPanel.width
    height = window.innerHeight - GUI.TopBar.height
    wFrac = width / initialSize.width
    hFrac = height / initialSize.height
    center.x = width/2
    center.y = height/2 + GUI.TopBar.height
    center.z = .9 * Math.min wFrac, hFrac
    render()
  
  
  requestRender = ()->
    RAF render, true
  
  
  render = ()->
    z = center.z * Math.pow 2, pos.z
    if z is Infinity then throw "FUCK"
    SVG.attr nav, "transform", "translate(#{pos.x+ox},#{pos.y+oy})"
    SVG.attr zoom, "transform", "translate(#{center.x},#{center.y}) scale(#{z})"
  
  
  limit = (l, v)->
    Math.min l.max, Math.max l.min, v
  
  Make "Nav", Nav =
    to: (p)->
      timeX = .03 * Math.sqrt(Math.abs(p.x-pos.x)) or 0
      timeY = .03 * Math.sqrt(Math.abs(p.y-pos.y)) or 0
      timeZ = .7 * Math.sqrt(Math.abs(p.z-pos.z)) or 0
      time = Math.sqrt timeX*timeX + timeY*timeY + timeZ*timeZ
      # TODO: Update this to use a tweened object
      Tween pos.x, p.x, time, ((v)->pos.x=v) if p.x?
      Tween pos.y, p.y, time, ((v)->pos.y=v) if p.y?
      Tween pos.z, p.z, time, ((v)->pos.z=v) if p.z?
    
    by: (p)->
      pos.z = limit zLimit, pos.z + p.z if p.z?
      scale = center.z * Math.pow 2, pos.z
      pos.x = limit xLimit, pos.x + p.x / scale if p.x?
      pos.y = limit yLimit, pos.y + p.y / scale if p.y?
      requestRender()
    
    startScale: ()->
      scaleStartPosZ = pos.z
    
    scale: (s)->
      pos.z = limit zLimit, Math.log2(Math.pow(2, scaleStartPosZ) * s)
      requestRender()
    
    eventInside: (e)->
      e = e.touches[0] if e.touches?.length > 0
      return e.target is document.rootElement or zoom.contains e.target
  
  
  distTo = (a, b)->
    dx = a.x - b.x
    dy = a.y - b.y
    dz = 200 * a.z - b.z
  
  dist = (x, y, z = 0)->
    Math.sqrt x*x + y*y + z*z
