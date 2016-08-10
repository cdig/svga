Take ["Config", "RAF", "Resize", "SVG", "Tween", "ScopeReady"], (Config, RAF, Resize, SVG, Tween)->
  if not Config.nav
    Make "Nav", false
    width = SVG.attr SVG.root, "width"
    height = SVG.attr SVG.root, "height"
    root = document.getElementById "root"
    Resize ()->
      wFrac = window.innerWidth / width
      hFrac = window.innerHeight / height
      scale = Math.min wFrac, hFrac
      x = (window.innerWidth - width * scale) / (2 * scale)
      y = (window.innerHeight - height * scale) / (2 * scale)
      SVG.attr root, "transform", "scale(#{scale}) translate(#{x}, #{y})"
  
  else
    SVG.attrs SVG.root, width: null, height: null
    pos = x: 0, y: 0, z: 0
    center = x: 0, y: 0, z: 1
    xLimit = {}
    yLimit = {}
    zLimit = min: 0, max: 3
    scaleStartPosZ = 0
    tween = null
    
    # This is the #root symbol, not the rootElement aka <svg>
    root = document.getElementById "root"
    
    initialSize = root.getBoundingClientRect()
    return unless initialSize.width > 0 and initialSize.height > 0 # This avoids a divide by zero error when the SVG is empty
    ox = root._scope.x - initialSize.left - initialSize.width/2
    oy = root._scope.y - initialSize.top - initialSize.height/2
    xLimit.max = initialSize.width/2
    yLimit.max = initialSize.height/2
    xLimit.min = -xLimit.max
    yLimit.min = -yLimit.max
    
    
    requestRender = ()->
      RAF render, true
    
    
    render = ()->
      z = center.z * Math.pow 2, pos.z
      SVG.attr root, "transform", "translate(#{center.x},#{center.y}) scale(#{z}) translate(#{pos.x+ox},#{pos.y+oy})"
    
    
    limit = (l, v)->
      Math.min l.max, Math.max l.min, v
    
    Make "Nav", Nav =
      to: (p)->
        timeX = .03 * Math.sqrt(Math.abs(p.x-pos.x)) or 0
        timeY = .03 * Math.sqrt(Math.abs(p.y-pos.y)) or 0
        timeZ = .7 * Math.sqrt(Math.abs(p.z-pos.z)) or 0
        time = Math.sqrt timeX*timeX + timeY*timeY + timeZ*timeZ
        tween = Tween pos, p, time, mutate:true, tick:render
      
      by: (p)->
        Tween.cancel tween if tween?
        pos.z = limit zLimit, pos.z + p.z if p.z?
        scale = center.z * Math.pow 2, pos.z
        pos.x = limit xLimit, pos.x + p.x / scale if p.x?
        pos.y = limit yLimit, pos.y + p.y / scale if p.y?
        requestRender()
      
      startScale: ()->
        scaleStartPosZ = pos.z
      
      scale: (s)->
        Tween.cancel tween if tween?
        pos.z = limit zLimit, Math.log2(Math.pow(2, scaleStartPosZ) * s)
        requestRender()
      
      eventInside: (e)->
        e = e.touches[0] if e.touches?.length > 0
        return e.target is document.rootElement or root.contains e.target
      
      assignSpace: (rect)->
        wFrac = rect.w / initialSize.width
        hFrac = rect.h / initialSize.height
        c =
         x: rect.x + rect.w/2
         y: rect.y + rect.h/2
         z: .9 * Math.min wFrac, hFrac
        if center.x is 0 # Initial render
          center = c
          render()
        else # Resize
          Tween center, c, 0.5, mutate:true, tick:render
    
    distTo = (a, b)->
      dx = a.x - b.x
      dy = a.y - b.y
      dz = 200 * a.z - b.z
    
    dist = (x, y, z = 0)->
      Math.sqrt x*x + y*y + z*z
