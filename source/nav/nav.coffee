Take ["ControlPanel", "Mode", "RAF", "Resize", "SVG", "Tween", "SceneReady"], (ControlPanel, Mode, RAF, Resize, SVG, Tween)->

  # Our SVGs don't have a viewbox, which means they render at 1:1 scale with surrounding content,
  # and are cropped when resized. We use their specified width and height as the desired bounding rect for the content.
  contentWidth = SVG.attr SVG.svg, "width"
  contentHeight = SVG.attr SVG.svg, "height"
  throw new Error "This SVG is missing the required 'width' and 'height' attributes. Please re-export it from Flash." unless contentWidth? and contentHeight?
  
  initialRootRect = SVG.root.getBoundingClientRect()
  return unless initialRootRect.width > 0 and initialRootRect.height > 0 # This avoids a divide by zero error when the SVG is empty
  
  pos = x: 0, y: 0, z: 0
  center = x: 0, y: 0
  centerInverse = x: 0, y: 0
  limit =
    x: min: -contentWidth/2, max: contentWidth/2
    y: min: -contentHeight/2, max: contentHeight/2
    z: min: -0.5, max: 3
  windowScale = 1
  scaleStartPosZ = 0
  tween = null
  
  
  render = ()->
    # First, we move SVG.root so the top left corner is in the middle of our available space.
    # ("Available space" means the size of the window, minus the space occupied by the control panel.)
    # Then, we scale to fit to the available space (windowScale) and desired zoom level (Math.pow 2, pos.z).
    # Then we shift back up and to the left to compensate for the first step (centerInverse), and then move to the desired nav position (pos).
    SVG.attr SVG.root, "transform", "translate(#{center.x},#{center.y}) scale(#{windowScale * Math.pow 2, pos.z}) translate(#{pos.x - centerInverse.x},#{pos.y - centerInverse.y})"
  
  
  # TODO: We need to find a way to delay this until after the ControlPanel is resized
  # Otherwise, we get inconsistency when near the vertical/horizontal crossover point
  # As a temporary fix, we call resize() from getAutosizePanelInfo
  Resize ()->
    
    # We need to use getBoundingClientRect() on our full-screen <svg>, because window.innerWidth/Height are sometimes 0 or wrong, depending on where we are in the load/init process.
    totalSpace = SVG.svg.getBoundingClientRect()
    
    # Figure out whether to leave room for the panel, or just scale to fit the full window.
    # (Note: Only one of panelInfo.w and panelInfo.h will be non-zero, based on whether we're in vertical or horizontal mode.)
    # (Eg: If the panel is in the bottom right corner, then we'll make room for it on the side when vertical, bottom when horizontal.)
    # Note: We look for values greater than 0.9, because there are a lot of modules that used 0.9 (instead of 1) as a way to get rounded corners in v3.
    panelInfo = ControlPanel.getAutosizePanelInfo()
    panelClaimedW = if Math.abs(panelInfo.signedX) >= 0.9 then panelInfo.w else 0
    panelClaimedH = if Math.abs(panelInfo.signedY) >= 0.9 then panelInfo.h else 0
    
    # Figure out how much space is available for our main graphic, and whether it should be shifted away from the top/left to make room for the panel
    availableSpaceW = totalSpace.width - panelClaimedW
    availableSpaceH = totalSpace.height - panelClaimedH
    availableSpaceX = if panelInfo.signedX < 0 then panelInfo.w else 0
    availableSpaceY = if panelInfo.signedY < 0 then panelInfo.h else 0
    
    # Scale the graphic so it fits inside our available space
    wFrac = availableSpaceW / contentWidth
    hFrac = availableSpaceH / contentHeight
    windowScale = Math.min wFrac, hFrac
    
    # Before scaling, we need to move the top left corner of the graphic to the center of the available space
    center.x = availableSpaceX + availableSpaceW/2
    center.y = availableSpaceY + availableSpaceH/2
    
    # After scaling, we need to move the top left corner of the graphic up and left, so the center of the graphic is aligned with the center of the consumed space
    centerInverse.x = contentWidth/2
    centerInverse.y = contentHeight/2
    
    render()
  
  
  # BAIL IF WE'RE NOT NAV-ING
  if not Mode.nav
    Make "Nav", false
    return
  
  
  requestRender = ()->
    RAF render, true
  
  applyLimit = (l, v)->
    Math.min l.max, Math.max l.min, v
    
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
      pos.z = applyLimit limit.z, pos.z + p.z if p.z?
      scale = Math.pow 2, pos.z
      pos.x = applyLimit limit.x, pos.x + p.x / scale if p.x?
      pos.y = applyLimit limit.y, pos.y + p.y / scale if p.y?
      requestRender()
    
    at: (p)->
      Tween.cancel tween if tween?
      pos.z = applyLimit limit.z, p.z if p.z?
      scale = Math.pow 2, pos.z
      pos.x = applyLimit limit.x, p.x / scale if p.x?
      pos.y = applyLimit limit.y, p.y / scale if p.y?
      requestRender()
    
    startScale: ()->
      scaleStartPosZ = pos.z
    
    scale: (s)->
      Tween.cancel tween if tween?
      pos.z = applyLimit limit.z, Math.log2(Math.pow(2, scaleStartPosZ) * s)
      requestRender()
    
    eventInside: (e)->
      e = e.touches[0] if e.touches?.length > 0
      e.target is document.body or e.target is SVG.svg or SVG.root.contains e.target
    
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
