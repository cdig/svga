Take ["defaultElement", "FlowArrows", "Global", "PureDom", "Reaction", "SVGStyle", "SVGTransform", "load"],
(      defaultElement ,  FlowArrows ,  Global ,  PureDom ,  Reaction ,  SVGStyle ,  SVGTransform)->
  
  symbolFns = {}
    
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
  
  Make "RootBuilder", activity =
    
    registerInstance: (instanceName, symbolFn)->
      console.log "Component registerInstance"
      symbolFns[instanceName] = symbolFn
    
    setupSvg: (svg)->
      symbol.registerInstance "default", defaultElement # Why is this here?
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
