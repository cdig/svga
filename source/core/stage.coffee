Take ["button", "crank", "defaultElement", "FlowArrows", "Global", "Joystick", "PureDom", "Reaction", "SetupGraphic", "slider", "SVGStyle", "SVGTransform", "DOMContentLoaded"],
(      button ,  crank ,  defaultElement ,  FlowArrows ,  Global ,  Joystick ,  PureDom ,  Reaction ,  SetupGraphic ,  slider ,  SVGStyle ,  SVGTransform)->
  
  
  setupColorMatrix = (defs, name, matrixValue)->
    filter = document.createElementNS "http://www.w3.org/2000/svg", "filter"
    filter.setAttribute "id", name
    colorMatrix = document.createElementNS "http://www.w3.org/2000/svg", "feColorMatrix"
    colorMatrix.setAttribute "in", "SourceGraphic"
    colorMatrix.setAttribute "type", "matrix"
    colorMatrix.setAttribute "values", matrixValue
    filter.appendChild colorMatrix
    defs.appendChild filter
  
    
  setupGraphic = (svg)->
    defs = svg.querySelector "defs"
    
    setupColorMatrix defs, "highlightMatrix", ".5  0   0    0   0
                                               .5  1   .5   0  20
                                               0   0   .5   0   0
                                               0   0   0    1   0"

    setupColorMatrix defs, "greyscaleMatrix", ".33 .33 .33  0   0
                                               .33 .33 .33  0   0
                                               .33 .33 .33  0   0
                                               0   0   0    1   0"

    setupColorMatrix defs, "allblackMatrix",  "0   0   0    0   0
                                               0   0   0    0   0
                                               0   0   0    0   0
                                               0   0   0    1   0"
  
  
  buildInstance = (name, elm)->
    fn = symbolFns[name] or symbolFns["default"]
    fn elm
  
  
  getChildElements = (element)->
    children = PureDom.querySelectorAllChildren(element, "g")
    childElements = []
    childNum = 0
    for child in children
      if not child.getAttribute("id")?
        childNum++
        childRef = "child" + childNum
        child.setAttribute("id", childRef)
      childElements.push child
    return childElements
  
  
  setupElement = (parent, element)->
    id = element.getAttribute("id").split("_")[0]
    instance = buildInstance id, element
    parent[id] = instance
    parent.children.push instance
    instance.children = []
    instance.element = element
    instance.getElement = ()-> return element
    instance.global = Global
    instance.root = parent.root
    instance.style = SVGStyle element
    instance.transform = SVGTransform element
    if element.getAttribute("id")?.indexOf("Line") > -1
      Reaction "animateMode", ()-> element.removeAttribute "filter"
      Reaction "schematicMode", ()-> element.setAttribute "filter", "url(#allblackMatrix)"
    setupElement instance, child for child in getChildElements element
  
  Make "Stage", (activity)->
    symbolFns = {}
    
    activity.defaultElement = defaultElement
    activity.registerInstance "joystick", "joystick"
    activity.crank = crank
    activity.button = button
    activity.slider = slider
    activity.joystick = Joystick
    
    svg = SetupGraphic svgaElmData.objectElm.contentDocument.querySelector "svg"

    
    for instance in activity._waitingInstances
      stage.internInstance(instance.graphicName, activity[instance.symbolName])
    stage.internInstance "default", activity.defaultElement
    stage.completeSetup svg
    Make id, stage.root
    
    internInstance = (instanceName, symbolFn)->
      symbolFns[instanceName] = symbolFn
    
    completeSetup = (svg)->
      activity.internInstance "default", defaultElement # Why is this here?
      root = buildInstance "root", svg
      Make "root", root
      root.FlowArrows = new FlowArrows()
      root.getElement = ()-> svg
      root.global = Global
      root.root = root
      root.children = []
      setupElement root, child for child in getChildElements svg
      svg.style.transition = "opacity .7s .1s"
      svg.style.opacity = 1
      null
