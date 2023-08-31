Take ["Action", "ControlPanel", "Fullscreen", "Mode", "ParentData", "RAF", "Resize", "SVG", "Tween", "SceneReady"], (Action, ControlPanel, Fullscreen, Mode, ParentData, RAF, Resize, SVG, Tween)->

  # Turn this on if we need to debug resizing
  # debugBox = SVG.create "rect", SVG.root, fill:"none", stroke:"#0F0A", strokeWidth: 6

  # Our SVGs don't have a viewbox, which means they render at 1:1 scale with surrounding content,
  # and are cropped when resized. We use their specified width and height as the desired bounding rect for the content.
  contentWidth = +SVG.attr SVG.svg, "width"
  contentHeight = +SVG.attr SVG.svg, "height"
  throw new Error "This SVG is missing the required 'width' and 'height' attributes. Please re-export it from Flash." unless contentWidth? and contentHeight?

  pos = x: 0, y: 0, z: 0
  center = x: 0, y: 0
  centerInverse = x: 0, y: 0
  limit =
    x: min: -contentWidth/2, max: contentWidth/2
    y: min: -contentHeight/2, max: contentHeight/2
    z: min: -1, max: 6
  contentScale = 1
  scaleStartPosZ = 0
  tween = null

  rootScale = ()-> contentScale * Math.pow 2, pos.z


  render = ()->
    # First, we move SVG.root so the top left corner is in the middle of our available space.
    # ("Available space" means the size of the window, minus the space occupied by the control panel.)
    # Then, we scale to fit to the available space (contentScale) and desired zoom level (Math.pow 2, pos.z).
    # Then we shift back up and to the left to compensate for the first step (centerInverse), and then move to the desired nav position (pos).
    SVG.attr SVG.root, "transform", "translate(#{center.x},#{center.y}) scale(#{rootScale()}) translate(#{pos.x - centerInverse.x},#{pos.y - centerInverse.y})"

    # Also notifiy any listeners that the Nav was just updated
    Action "Nav"


  pickBestLayout = (totalAvailableSpace, horizontalResizeInfo, verticalResizeInfo)->
    if Mode.embed
      # Prefer vertical, if that doesn't cause our content to shrink
      return verticalResizeInfo if verticalResizeInfo.scale.min >= 1

      # Failing that, prefer hozitontal, if there's enough screen height
      contentHeightWhenHorizontal = contentHeight * horizontalResizeInfo.scale.min
      panelHeightWhenHorizontal = horizontalResizeInfo.panelInfo.consumedSpace.h
      return horizontalResizeInfo if totalAvailableSpace.h > contentHeightWhenHorizontal + panelHeightWhenHorizontal

    # Take whichever panel layout leaves more room for content
    if horizontalResizeInfo.scale.min > verticalResizeInfo.scale.min
      horizontalResizeInfo
    else
      verticalResizeInfo


  computeResizeInfo = (totalAvailableSpace, panelInfo)->
    # Figure out how much space remains for our main graphic
    totalAvailableContentSpace =
      w: totalAvailableSpace.w - panelInfo.consumedSpace.w
      h: totalAvailableSpace.h - panelInfo.consumedSpace.h

    # Scale the graphic so it fits inside our available space
    scale =
      x: totalAvailableContentSpace.w / contentWidth
      y: totalAvailableContentSpace.h / contentHeight
    scale.min = Math.min scale.x, scale.y

    idealHeight = if Mode.embed
      idealContentHeight = scale.x * contentHeight
      claimedH = idealContentHeight + panelInfo.consumedSpace.h
      Math.min totalAvailableSpace.h, Math.max claimedH, panelInfo.outerPanelSize.h
    else
      totalAvailableSpace.h

    return resizeInfo =
      panelInfo: panelInfo
      totalAvailableContentSpace: totalAvailableContentSpace
      idealHeight: idealHeight
      scale: scale


  resize = ()->

    # This is the largest our SVGA can ever be
    if Mode.embed
      innerHeight = ParentData.get("windowTopInnerHeight")
    else
      innerHeight = window.top.innerHeight
      
    totalAvailableSpace =
      w: SVG.svg.getBoundingClientRect().width
      h: innerHeight

    # When deployed, account for the floating header
    if not Mode.dev and not Fullscreen.active()
      totalAvailableSpace.h -= 48

    # Sometimes the size will be explicitly set by our embedder, overriding the above
    if Mode.embed
      totalAvailableSpace.w = forcedWidth if forcedWidth = ParentData.get "forcedWidth"
      totalAvailableSpace.h = forcedHeight if forcedHeight = ParentData.get "forcedHeight"

    # Build two layouts — we'll figure out which one is best for the current content, controls, and screen size.
    verticalPanelInfo = ControlPanel.computeLayout true, totalAvailableSpace
    horizontalPanelInfo = ControlPanel.computeLayout false, totalAvailableSpace

    # Measure both layouts
    verticalResizeInfo = computeResizeInfo totalAvailableSpace, verticalPanelInfo
    horizontalResizeInfo = computeResizeInfo totalAvailableSpace, horizontalPanelInfo

    # Pick the best layout
    resizeInfo = pickBestLayout totalAvailableSpace, horizontalResizeInfo, verticalResizeInfo

    # If we're embedded into a cd-module, resize our embedding object.
    if Mode.embed
      ParentData.send "height", Math.round(resizeInfo.idealHeight) + "px"
      totalAvailableSpace.h = resizeInfo.idealHeight

    # Apply the chosen layout to the ControlPanel
    ControlPanel.applyLayout resizeInfo, totalAvailableSpace

    # Save our window scale for future nav actions
    contentScale = resizeInfo.scale.min

    # Before we do any scale operations, we need to move the top left corner of the graphic to the center of the available space
    center.x = resizeInfo.totalAvailableContentSpace.w/2
    center.y = resizeInfo.idealHeight/2 - resizeInfo.panelInfo.consumedSpace.h/2

    # After we do any scale operations, we need to move the top left corner of the graphic up and left, so the center of the graphic is aligned with the center of the consumed space
    centerInverse.x = contentWidth/2
    centerInverse.y = contentHeight/2

    render()

    # Turn this on if we need to debug resizing
    # SVG.attrs debugBox, width: contentWidth, height: contentHeight

    Resize._fire
      window: totalAvailableSpace
      panel:
        scale: resizeInfo.panelInfo.scale
        vertical: resizeInfo.panelInfo.vertical
        x: resizeInfo.panelInfo.x
        y: resizeInfo.panelInfo.y
        width: resizeInfo.panelInfo.outerPanelSize.w
        height: resizeInfo.panelInfo.outerPanelSize.h
      content:
        width: contentWidth
        height: contentHeight


  # Init
  runResize = ()-> RAF resize, true
  window.addEventListener "resize", runResize
  if not Mode.embed
    window.top.addEventListener "resize", runResize
  Take "AllReady", runResize


  if Mode.embed
    # This is noisy, but we don't currently have a way to limit listeners to just resize-relevant events
    ParentData.listen runResize


  # BAIL IF WE'RE NOT NAV-ING
  unless Mode.nav
    Make "Nav", false
    return


  requestRender = ()->
    RAF render, true

  applyLimit = (l, v, a = 0)->
    Math.min l.max + a, Math.max l.min - a, v

  Make "Nav", Nav =
    center: ()-> center
    pos: ()-> pos
    rootScale: rootScale

    runResize: runResize

    reset: (time)-> Nav.to {x:0, y:0, z:0}, time

    to: (p, time)->
      Tween.cancel tween if tween?
      time ?= Nav.tweenTime p
      tween = Tween pos, p, time, mutate:true, tick:render

    by: (p)->
      Tween.cancel tween if tween?
      pos.z = applyLimit limit.z, pos.z + p.z if p.z?
      scale = rootScale()
      pos.x += p.x / scale if p.x?
      pos.y += p.y / scale if p.y?
      pos.x = applyLimit limit.x, pos.x, center.x / scale * .8
      pos.y = applyLimit limit.y, pos.y, center.y / scale * .8
      requestRender()

    at: (p)->
      Tween.cancel tween if tween?
      pos.z = applyLimit limit.z, p.z if p.z?
      scale = rootScale()
      pos.x = p.x / scale if p.x?
      pos.y = p.y / scale if p.y?
      pos.x = applyLimit limit.x, pos.x, center.x / scale * .8
      pos.y = applyLimit limit.y, pos.y, center.y / scale * .8
      requestRender()

    startScale: ()->
      scaleStartPosZ = pos.z

    scale: (s)->
      Tween.cancel tween if tween?
      pos.z = applyLimit limit.z, Math.log2(Math.pow(2, scaleStartPosZ) * s)
      requestRender()

    tweenTime: (p)->
      timeX = .03 * Math.sqrt(Math.abs(p.x-pos.x)) or 0
      timeY = .03 * Math.sqrt(Math.abs(p.y-pos.y)) or 0
      timeZ = .7 * Math.sqrt(Math.abs(p.z-pos.z)) or 0
      return Math.sqrt timeX*timeX + timeY*timeY + timeZ*timeZ

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
