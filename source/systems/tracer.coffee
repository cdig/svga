Take ["Control", "Input", "Resize", "Scope", "SVG", "Vec"], (Control, Input, Resize, Scope, SVG, Vec)->

  # Nav doesn't exist until after Symbol registration closes, so if we added it to Take,
  # Symbols (like root, in the animation code) wouldn't be able to take Tracer.
  Nav = null
  Take "Nav", (N)-> Nav = N

  editing = false

  activeConfig = null


  # HELPERS #########################################################################################


  getFullPathId = (path)->
    fullId = path.id
    parent = path.parent
    while parent? and parent.id isnt "root"
      fullId = parent.id + "." + fullId
      parent = parent.parent
    "@#{fullId}"


  # SETUP #########################################################################################


  setupPaths = ()->
    for path in activeConfig.paths
      if not path? then throw "One of the paths given to Tracer is null"
      initializePath path unless path.tracer?
      stylePath path
    null


  initializePath = (path)->
    return if path.tracer?

    path.tracer =
      glows: []
      hits: []
      clicking: false
      hovering: false
      clickCount: 0
      desiredClicks: 0

    # Sort to top
    path.element.parentNode.appendChild path.element

    # Block double-click nav reset
    path.element.setAttribute "block-dbl", true

    # Build decorations
    for child in path.children
      buildGlow path, child
      buildHit path, child

    calls =
      down: startClick path
      drag: cancelClick path
      click: clickPath path
    Input path.element, calls, true, false


  buildGlow = (path, child)->
    scope = cloneChild path, child
    path.tracer.glows.push scope
    scope.strokeWidth = 3


  buildHit = (path, child)->
    scope = cloneChild path, child, hitDefn
    path.tracer.hits.push scope
    scope.strokeWidth = 10
    calls =
      moveIn: hitMoveIn path
      moveOut: hitMoveOut path
    Input scope.element, calls, true, false


  cloneChild = (path, child, defn)->
    elm = child.element.cloneNode true
    path.element.appendChild elm
    Scope elm, defn


  hitDefn = (elm)->
    tick: hitTick = ()->
      @strokeWidth = Math.max 3, 20 / Nav.rootScale() if Nav?


  # STYLE #########################################################################################


  stylePath = (path)->
    colorIndex = path.tracer.clickCount % activeConfig.colors.length
    color = activeConfig.colors[colorIndex] or "#000"

    isUncolored = colorIndex is 0
    isHover = path.tracer.hovering
    isDefault = isUncolored and !isHover

    path.stroke = color

    for child in path.children
      child.alpha = switch
        when isUncolored and !isHover then 0
        when isUncolored and isHover then 0
        when !isUncolored and isHover then 1
        when !isUncolored and !isHover then 1

    for glow in path.tracer.glows
      glow.stroke = color
      glow.alpha = switch
        when isUncolored and !isHover then .08
        when isUncolored and isHover then .3
        when !isUncolored and isHover then 0
        when !isUncolored and !isHover then 0

    for hit in path.tracer.hits
      hit.stroke = color
      hit.alpha = if isHover then .2 else 0.001
      hit.alpha = switch
        when isUncolored and !isHover then .001
        when isUncolored and isHover then .07
        when !isUncolored and isHover then .15
        when !isUncolored and !isHover then .001


  # EVENTS ########################################################################################


  hitMoveIn = (path)-> ()->
    return unless activeConfig
    path.tracer.hovering = true
    stylePath path


  hitMoveOut = (path)-> ()->
    return unless activeConfig
    path.tracer.hovering = false
    stylePath path


  startClick = (path)-> (e)->
    return unless activeConfig
    path.tracer.clicking = x: e.clientX, y: e.clientY


  cancelClick = (path)-> (e)->
    return unless activeConfig
    if path.tracer.clicking?
      d = Vec.distance path.tracer.clicking, x: e.clientX, y: e.clientY
      path.tracer.clicking = null if d >= 5


  clickPath = (path)-> (e)->
    return unless activeConfig
    return unless path.tracer.clicking?
    id = getFullPathId path

    if editing
      editClick path, id, e
    else
      gameClick path, id


  editClick = (path, id, e)->
    if e.altKey
      console.log "Clicked #{id}"
    else
      incPath path


  gameClick = (path, id)->
    if (reaction = activeConfig.reactions[id])?
      reaction()
    else
      incPath path
      activeConfig.onWin() if checkForSolution path


  incPath = (path)->
    path.tracer.clickCount++
    stylePath path


  # GAMEPLAY ######################################################################################


  setupGame = ()->
    # For the paths that are part of a solution, set them to the correct color
    for set, setIndex in activeConfig.solution
      colorIndex = setIndex + 1
      for path in set
        path.tracer.desiredClicks = colorIndex

    null



  checkForSolution = ()->
    incorrectPaths = []
    nSets = activeConfig.colors.length
    for path in activeConfig.paths
      if path.tracer.clickCount % nSets isnt path.tracer.desiredClicks
        incorrectPaths.push path
    return incorrectPaths.length is 0


  # EDITING #######################################################################################


  setupEditing = ()->
    editing = true

    Control.label
      name: "Path Tracer Edit Mode"
      group: "#F80"

    Control.button
      name: "Copy Solution"
      group: "#F80"
      click: saveConfiguration

    if Nav?
      Nav.runResize() # This is needed to make the new panel buttons appear

      debugPoint = Scope SVG.create "g", SVG.svg
      debugPoint.debug.point()
      debugPoint.hide 0

      Resize ()->
        debugPoint.x = Nav.center().x
        debugPoint.y = Nav.center().y

      window.addEventListener "keydown", (e)-> debugPoint.show 0 if e.keyCode is 32
      window.addEventListener "keyup", (e)->
        debugPoint.hide 0 if e.keyCode is 32
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
    lines = for paths in solution
      pathsString = paths.map(getFullPathId).join ", "
      "          [\"#{pathsString}\"]\n"
    text = "solution: [\n#{lines.join('')}        ]"

    # Put the solution coffeescript text onto the clipboard
    navigator.clipboard.writeText(text).then ()-> console.log "Copied current configuration to clipboard"


  # MAIN ##########################################################################################


  Make "Tracer",
    edit: (config)->
      return if editing
      activeConfig = config
      setupPaths()
      setupEditing()

    play: (config)->
      return if editing
      activeConfig = config
      setupPaths()
      setupGame()

    stop: ()->
      if activeConfig?
        saveConfiguration() if editing
        editing = false

        for path in activeConfig.paths
          needsStyle = path.tracer.clickCount isnt 0
          path.tracer.clicking = false
          path.tracer.hovering = false
          path.tracer.clickCount = 0
          path.tracer.desiredClicks = 0
          stylePath path if needsStyle

      activeConfig = null
