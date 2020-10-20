Take ["Control", "Panel", "Reaction", "Resize", "SVG", "Scope", "Tick", "Tween", "Vec", "Wait"], (Control, Panel, Reaction, Resize, SVG, Scope, Tick, Tween, Vec, Wait)->

  # Nav doesn't exist until after Symbol registration closes, so if we added it to Take,
  # Symbols (like root, in the animation code) wouldn't be able to take Tracer.
  Nav = null
  Take "Nav", (N)-> Nav = N

  activeConfig = null
  hoveredPath = null
  editing = false
  xShape = "M-1,-1 L1,1 M-1,1 L1,-1"
  checkShape = "M-1,0 L-.3,.8 L1,-1"


  # HELPERS #########################################################################################


  getFullPathId = (path)->
    fullId = path.id
    parent = path.parent
    while parent? and parent.id isnt "root"
      fullId = parent.id + "." + fullId
      parent = parent.parent
    "@#{fullId}"


  cloneChild = (path, child)->
    elm = child.element.cloneNode true
    path.element.appendChild elm
    elm


  eventInside = (e)->
    e = e.touches[0] if e.touches?.length > 0
    e.target is document.body or e.target is SVG.svg or SVG.root.contains e.target


  # SETUP #########################################################################################


  setupPaths = ()->
    for path in activeConfig.paths
      if not path? then throw "One of the paths given to Tracer is null"
      unless path.tracer?
        setupPathEvents path
        createTracerProp path
      resetTracerProp path

    for set, setIndex in activeConfig.solution
      setupSolutionSet set, setIndex

    for path in activeConfig.paths
      stylePath path

    updateZoomScaling true, true


  setupPathEvents = (path)->
    # TODO: The move and up events need to go on window
    # Maybe we do a single listener on window that just handles drag distance,
    # and then a down and up handler on each element checks whether we should click it
    start = startClick path
    cancel = cancelClick path
    click = clickPath path
    path.element.addEventListener "mousedown", start
    path.element.addEventListener "mousemove", cancel
    path.element.addEventListener "mouseup", click
    path.element.addEventListener "touchstart", start
    path.element.addEventListener "touchmove", cancel
    path.element.addEventListener "touchend", click # Hack: Input touchend preventDefault blocks click


  createTracerProp = (path)->
    path.tracer =
      originalChildren: Array.from path.element.children
      glows: buildGlow path, child for child in path.children
      hits: buildHit path, child for child in path.children
      badge: buildBadge path
      bb: path.children[0].element.getBBox()


  resetTracerProp = (path)->
    path.tracer.clicking = false
    path.tracer.hovering = false
    path.tracer.clickCount = 0
    path.tracer.desiredClicks = 0
    path.tracer.clickPos = null
    path.tracer.animstate = null
    path.tracer.isCorrect = true
    path.tracer.isMistake = false
    path.tracer.tween = null
    path.tracer.badge.alpha = false


  buildGlow = (path, child)->
    scope = Scope cloneChild path, child
    scope.strokeWidth = 3
    scope


  buildHit = (path, child)->
    scope = Scope cloneChild path, child
    scope.strokeWidth = 10
    scope.element.addEventListener "mouseenter", hitMoveIn path
    scope.element.addEventListener "mouseleave", hitMoveOut path
    scope


  buildBadge = (path)->
    # The transform on this element is used to put it in the right position
    scope = Scope SVG.create "g", path.element,
      class: "tracer-badge"
      fill: "none"
      strokeLinecap: "round"
    scope.alpha = false

    # The transform on this element is used for zoom-based scaling
    scope.zoomScale = SVG.create "g", scope.element

    scope.shadow = SVG.create "path", scope.zoomScale, strokeWidth: 1, stroke: "white"
    scope.shape = SVG.create "path", scope.zoomScale, strokeWidth: .5
    scope


  setupSolutionSet = (set, setIndex)->
    colorIndex = setIndex + 1
    for path in set
      path.tracer.desiredClicks = colorIndex
      path.tracer.clickCount = colorIndex if editing
      path.tracer.isCorrect = false

      # Sort this wire to the top, so that it's easier to click on than unused wires
      path.element.parentNode.appendChild path.element


  # ZOOM-BASED SCALING ############################################################################
  lastScale = null
  stableCounter = 10


  Reaction "Nav", ()->
    return unless activeConfig?
    scale = Nav.rootScale()
    if scale isnt lastScale
      lastScale = scale
      stableCounter = 0
      updateZoomScaling false, true


  Tick ()->
    return unless activeConfig? and stableCounter?
    scale = Nav.rootScale()
    stableCounter++
    if stableCounter >= 10
      stableCounter = null
      updateZoomScaling true, false


  updateZoomScaling = (updateHits, updateBadges)->
    return unless activeConfig?
    scale = Nav.rootScale()
    badgeScale = Math.max 3, 8 / Math.pow scale, .5
    hitScale = Math.max 3, 20 / scale
    # path.parent.alpha is how we support multiple sheets — avoid scaling stuff on sheets that aren't visible
    for path in activeConfig.paths when path.parent.alpha > 0
      if updateHits or path is hoveredPath
        hit.strokeWidth = hitScale for hit in path.tracer.hits
      if updateBadges
        SVG.attrs path.tracer.badge.zoomScale, transform: "scale(#{badgeScale})"
    null


  # STYLING #######################################################################################


  stylePath = (path)->
    colorIndex = path.tracer.clickCount % activeConfig.colors.length

    color = activeConfig.colors[colorIndex] or "#000"

    isHover = path.tracer.hovering
    isColored = colorIndex isnt 0

    path.stroke = color

    for child in path.children when child isnt path.tracer.badge
      child.alpha = isColored

    for glow in path.tracer.glows
      glow.stroke = color
      glow.alpha = switch
        when !isColored and !isHover then .08
        when !isColored and isHover then .3
        when isColored and isHover then 0
        when isColored and !isHover then .15

    for hit in path.tracer.hits
      # Even when the color is "transparent", there's a sizable perf benefit to having opaque alpha
      hit.stroke = if isHover then color else "transparent"
      hit.alpha = if isHover then .2 else 1

    null


  updateBadge = (path)->
    if path.tracer.isMistake
      unless path.tracer.animstate is "incorrect"
        path.tracer.animstate = "incorrect"
        path.tracer.badge.stroke = "hsl(358, 80%, 55%)" # $red
        path.tracer.badge.scale = 2
        path.tracer.badge.alpha = 0
        path.tracer.badge.x = path.tracer.clickPos.x
        path.tracer.badge.y = path.tracer.clickPos.y
        SVG.attrs path.tracer.badge.shape, d: xShape
        SVG.attrs path.tracer.badge.shadow, d: xShape
        props =
          scale: 1
          alpha: 1
        Tween.cancel path.tracer.tween
        path.tracer.tween = Tween path.tracer.badge, props, .2
    else
      if path.tracer.animstate?
        path.tracer.animstate = null
        path.tracer.badge.stroke = "hsl(153, 80%, 41%)" # $mint
        SVG.attrs path.tracer.badge.shape, d: checkShape
        SVG.attrs path.tracer.badge.shadow, d: checkShape
        props =
          scale: 2
          alpha: 0
        Tween.cancel path.tracer.tween
        path.tracer.tween = Tween path.tracer.badge, props, 1


  unstylePath = (path)->
    path.stroke = "#000"
    child.alpha = 1 for child in path.children
    glow.alpha = 0 for glow in path.tracer.glows
    hit.alpha = 0 for hit in path.tracer.hits
    Tween.cancel path.tracer.tween
    path.tracer.badge.alpha = 0
    null


  # EVENTS ########################################################################################


  hitMoveIn = (path)-> ()->
    return unless activeConfig
    path.tracer.hovering = true
    hoveredPath = path
    stylePath path


  hitMoveOut = (path)-> ()->
    return unless activeConfig
    path.tracer.hovering = false
    hoveredPath = null if hoveredPath is path
    stylePath path


  startClick = (path)-> (e)->
    return unless activeConfig
    return unless eventInside e
    e = e.touches[0] if e.touches?.length > 0
    path.tracer.clicking = x: e.clientX, y: e.clientY


  cancelClick = (path)-> (e)->
    return unless activeConfig
    return unless eventInside e
    e = e.touches[0] if e.touches?.length > 0
    if path.tracer.clicking?
      d = Vec.distance path.tracer.clicking, x: e.clientX, y: e.clientY
      path.tracer.clicking = null if d >= 5


  clickPath = (path)-> (e)->
    return unless activeConfig
    return unless path.tracer.clicking?
    return unless eventInside e
    if editing
      editClick path
    else
      gameClick path


  setPathClickPos = (path)->
    # Create a point at the root of the SVG, and move it to the screen coords of the mouse position
    p_screen = SVG.svg.createSVGPoint()
    p_screen.x = path.tracer.clicking.x
    p_screen.y = path.tracer.clicking.y
    # Get a matrix that transfroms from screen coords to the coords of the path
    screenToPath = path.element.getScreenCTM().inverse()
    # Transform the point by that matrix
    p_path = p_screen.matrixTransform screenToPath
    # Now, find the point on the path that is closest to the mouse point
    stepSize = 10
    closestPoint = null
    closestDist = Infinity
    # This is assuming that each path will originally contain a single g elm,
    # which will contain one or more path elms.
    # This might not be true of all Tracer games. We'd need to revise it to,
    # perhaps, locate all <path> elements using querySelector or somesuch.
    for groupElm in path.tracer.originalChildren
      for pathElm in groupElm.children
        i = pathElm.getTotalLength()
        while i > 0
          p = pathElm.getPointAtLength i
          d = Vec.distance p, p_path
          if d < closestDist
            closestDist = d
            closestPoint = p
          i -= stepSize
    path.tracer.clickPos = closestPoint


  # GAMEPLAY ######################################################################################


  editClick = (path)->
    if e.altKey
      console.log "Clicked #{getFullPathId path}"
    else
      setPathClickPos path
      incPath path
      scorePath path
      stylePath path


  gameClick = (path)->
    if reaction = getReaction path
      reaction path
    else
      setPathClickPos path
      incPath path
      scorePath path
      stylePath path
      updateBadge path
      checkForFirstMistakeEver path
      checkForWin()


  getReaction = (path)->
    if activeConfig.reactions?.length > 0
      for reaction in activeConfig.reactions
        if path in reaction.paths
          return reaction.fn
    return null


  incPath = (path)->
    path.tracer.clickCount++


  delayedMistakePath = null


  scorePath = (path)->
    nSets = activeConfig.colors.length
    isCorrect = path.tracer.clickCount % nSets is path.tracer.desiredClicks
    clickedPastCorrect = path.tracer.clickCount > path.tracer.desiredClicks

    # Reset the path state
    path.tracer.isCorrect = false
    path.tracer.isMistake = false
    delayedMistakePath = null if delayedMistakePath is path

    # Now, set the path to the correct state
    if isCorrect
      path.tracer.isCorrect = true
    else if clickedPastCorrect
      path.tracer.isMistake = true
    else
      delayedMistakePath = path


  checkForIncorrectPaths = (e)->
    return unless activeConfig?
    return unless delayedMistakePath?
    return if delayedMistakePath.element.contains e.target
    delayedMistakePath.tracer.isMistake = true
    stylePath delayedMistakePath
    updateBadge delayedMistakePath
    checkForFirstMistakeEver delayedMistakePath, true
    delayedMistakePath = null
    null

  window.addEventListener "click", checkForIncorrectPaths, true
  window.addEventListener "touchend", checkForIncorrectPaths, true # Hack: Input touchend preventDefault blocks click


  getIncorrectPaths = ()->
    path for path in activeConfig.paths when not path.tracer.isCorrect


  checkForWin = ()->
    if getIncorrectPaths().length is 0
      activeConfig.onWin activeConfig


  # FEEDBACK ######################################################################################
  noMistakesEver = true


  checkForFirstMistakeEver = (path, forced)->
    return unless noMistakesEver
    isIncorrect = path.tracer.clickPos? and not path.tracer.isCorrect
    clickedPastCorrect = path.tracer.clickCount > path.tracer.desiredClicks
    if isIncorrect and (clickedPastCorrect or forced)
      Wait .5, ()-> Panel.alert """
        <h3>That path is incorrect.</h3>
        <p style="margin-top:.5em">
          To fix it, keep clicking the path.
        </p>
        <p style="margin-top:.5em">
          Once the path is set correctly for<br>
          this circuit, the
          <svg style="vertical-align:middle" width="1.2em" height="1.2em" viewBox="-2 -2 4 4" fill="none" stroke-linecap="round">
            <path stroke="#FFF" stroke-width="1.2" d="M-1,-1 L1,1 M-1,1 L1,-1"/>
            <path stroke-width=".7" stroke="hsl(358, 80%, 55%)" d="M-1,-1 L1,1 M-1,1 L1,-1"/>
          </svg>
          mark will disappear.
        </p>
      """
      noMistakesEver = false


  # EDITING #######################################################################################
  editingSetupDone = false


  setupEditing = ()->
    editing = true

    return if editingSetupDone
    editingSetupDone = true

    Control.label
      name: "Path Tracer Edit Mode"
      group: "#F80"

    Control.button
      name: "Copy Solution"
      group: "#F80"
      click: saveConfiguration

    Nav?.runResize() # This is needed to make the new panel buttons appear

    debugPoint = Scope SVG.create "g", SVG.svg
    debugPoint.debug.point()
    debugPoint.hide 0

    Resize ()->
      debugPoint.x = Nav.center().x
      debugPoint.y = Nav.center().y

    window.addEventListener "keydown", (e)-> debugPoint.show 0 if e.keyCode is 32
    window.addEventListener "keyup", (e)->
      if e.keyCode is 32
        debugPoint.hide 0
        console.log Nav.pos()


  saveConfiguration = ()->
    # Sort all selected paths into solution sets
    nSets = activeConfig.colors.length
    solution = ([] for c in [0...nSets])
    for path in activeConfig.paths
      colorIndex = path.tracer.clickCount % nSets
      solution[colorIndex].push path

    # We don't care about the paths in the default / un-clicked set
    solution.shift()

    # Format the solution sets into coffeescript text
    text = JSON.stringify solution: solution.map (paths)-> paths.map(getFullPathId)

    # Put the solution coffeescript text onto the clipboard
    navigator.clipboard.writeText(text).then ()-> console.log "Copied current configuration to clipboard"


  # MAIN ##########################################################################################


  Make "Tracer", Tracer =
    edit: (config)->
      Tracer.stop()
      activeConfig = config # We should probably clone the config, so we can mutate it without fear
      setupEditing()
      setupPaths()

    play: (config)->
      Tracer.stop()
      activeConfig = config # We should probably clone the config, so we can mutate it without fear
      setupPaths()

    stop: ()->
      if activeConfig?
        editing = false
        unstylePath path for path in activeConfig.paths
        activeConfig = null

    refresh: ()-> updateZoomScaling true, true
