Take ["ControlPanel", "RAF", "SVG", "Tween"], (ControlPanel, RAF, SVG, Tween)->
  
  boxTransformed = SVG.create "rect", SVG.svg, stroke: "#0F03", strokeWidth: "6", fill: "none"
  
  # HUD
  #   panelWidth: panelInfo.w
  #   panelHeight: panelInfo.h
  #   width: width
  #   height: height
  #   scale: scale
  
  Make "DynamicNav", ()->
    SVG.attrs SVG.svg, width: null, height: null
    pos = x: 0, y: 0, z: 0
    center = x: 0, y: 0, z: 1
    xLimit = {}
    yLimit = {}
    zLimit = min: -0.5, max: 3
    scaleStartPosZ = 0
    tween = null
    
    parentRect = SVG.svg.getBoundingClientRect()
    initialRect = SVG.root.getBoundingClientRect()
    
    return unless initialRect.width > 0 and initialRect.height > 0 # This avoids a divide by zero error when the SVG is empty
    ox = SVG.root._scope.x - (initialRect.left - parentRect.left) - initialRect.width/2
    oy = SVG.root._scope.y - (initialRect.top - parentRect.top) - initialRect.height/2
    xLimit.max = initialRect.width * 0.5
    yLimit.max = initialRect.height * 0.5
    xLimit.min = -xLimit.max
    yLimit.min = -yLimit.max
    
    requestRender = ()->
      RAF render, true
    
    render = ()->
      z = center.z * Math.pow 2, pos.z
      SVG.attr SVG.root, "transform", "translate(#{center.x},#{center.y}) scale(#{z}) translate(#{pos.x+ox},#{pos.y+oy})"
    
    limit = (l, v)->
      Math.min l.max, Math.max l.min, v
    
    Resize ()->
      Tween center, c, 0.5, mutate:true, tick:render
    
    Make "Nav", Nav =
      to: (p)->
        Tween.cancel tween if tween?
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
      
      at: (p)->
        Tween.cancel tween if tween?
        pos.z = limit zLimit, p.z if p.z?
        scale = center.z * Math.pow 2, pos.z
        pos.x = limit xLimit, p.x / scale if p.x?
        pos.y = limit yLimit, p.y / scale if p.y?
        requestRender()
      
      startScale: ()->
        scaleStartPosZ = pos.z
      
      scale: (s)->
        Tween.cancel tween if tween?
        pos.z = limit zLimit, Math.log2(Math.pow(2, scaleStartPosZ) * s)
        requestRender()
      
      eventInside: (e)->
        e = e.touches[0] if e.touches?.length > 0
        e.target is document.body or e.target is SVG.svg or SVG.root.contains e.target
      
      # assignSpace: (rect)->
      #   panelSpaceY = -ControlPanel.getAutosizePanelHeight()/2
      #   wFrac = rect.w / initialRect.width
      #   hFrac = rect.h / initialRect.height
      #   c =
      #    x: rect.x + rect.w/2
      #    y: rect.y + rect.h/2 + panelSpaceY
      #    z: .9 * Math.min wFrac, hFrac
      #   if center.x is 0 # Initial render
      #     center = c
      #     render()
      #   else # Resize
      #     Tween center, c, 0.5, mutate:true, tick:render
    
    distTo = (a, b)->
      dx = a.x - b.x
      dy = a.y - b.y
      dz = 200 * a.z - b.z
    
    dist = (x, y, z = 0)->
      Math.sqrt x*x + y*y + z*z
    
    
    # Enable this to debug nav repaints
    # Take "Tick", (Tick)->
    #   Tick (t)->
    #     Nav.at z: Math.sin(t)/10 - .1
