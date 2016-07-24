Take ["GUI", "RAF", "Resize", "SVG", "ScopeReady"], (GUI, RAF, Resize, SVG)->
  pos = x: 0, y: 0, z: 0
  center = x: 0, y: 0, z: 0
  xLimit = {}
  yLimit = {}
  zLimit = min: 0, max: 3
  scaleStartPosZ = 0
  
  zoom = SVG.create "g", null, "x-zoom":""
  nav = SVG.create "g", zoom, "x-nav":""
  root = document.getElementById "root" # This is the "root" symbol, not to be confused with the <svg> aka rootElement
  SVG.prepend document.rootElement, zoom
  SVG.append nav, root
  
  # Debug points
  # SVG.create "rect", nav, x:-8, y:-8, width:16, height:16, fill:"#F00"
  # SVG.create "rect", zoom, x:-6, y:-6, width:12, height:12, fill:"#F0F"
  
  initialSize = root.getBoundingClientRect()
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
  
  
  render = ()->
    RAF noReallyRender, true
  
  noReallyRender = ()->
    z = center.z * Math.pow 2, pos.z
    SVG.attr nav, "transform", "translate(#{pos.x+ox},#{pos.y+oy})"
    SVG.attr zoom, "transform", "translate(#{center.x},#{center.y}) scale(#{z})"
  
  
  limit = (l, v)->
    Math.min l.max, Math.max l.min, v
  
  Make "Nav", Nav =
    by: (p)->
      pos.z = limit zLimit, pos.z + p.z if p.z?
      pos.x = limit xLimit, pos.x + p.x / (1 + pos.z) if p.x?
      pos.y = limit yLimit, pos.y + p.y / (1 + pos.z) if p.y?
      render()
    
    startScale: ()->
      scaleStartPosZ = pos.z
    
    scale: (s)->
      pos.z = limit zLimit, Math.log2(Math.pow(2, scaleStartPosZ) * s)
      render()
    
    eventInside: (x, y)->
      panelHidden = false # !Control.panelShowing # TODO
      insidePanel = x < window.innerWidth - GUI.ControlPanel.width
      insideTopBar = y > GUI.TopBar.height
      return insideTopBar and (panelHidden or insidePanel)
