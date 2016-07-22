Take ["GUI", "Resize", "SVG", "ScopeReady"], (GUI, Resize, SVG)->
  pos = x: 0, y: 0, z: 0
  center = x: 0, y: 0, z: 0
  minLimit = z: 0 # Values for x and y are computed during init
  maxLimit = z: 3 # Values for x and y are computed during init
  
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
  maxLimit.x = initialSize.width/2
  maxLimit.y = initialSize.height/2
  minLimit.x = -maxLimit.x
  minLimit.y = -maxLimit.y
  
  
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
    z = center.z * Math.pow 2, pos.z
    SVG.attr nav, "transform", "translate(#{pos.x+ox},#{pos.y+oy})"
    SVG.attr zoom, "transform", "translate(#{center.x},#{center.y}) scale(#{z})"
  
  limit = (prop, v)->
    return Math.min maxLimit[prop], Math.max minLimit[prop], v
  
  Make "Nav", Nav =
    by: (p)->
      pos.z = limit "z", pos.z + p.z
      pos.x = limit "x", pos.x + p.x / (1 + pos.z)
      pos.y = limit "y", pos.y + p.y / (1 + pos.z)
      render()
  
