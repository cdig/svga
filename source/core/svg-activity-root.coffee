Take ["defaultElement", "Dispatch", "FlowArrows", "Global", "PureDom", "SVGStyle", "SVGTransform", "load"],
(      defaultElement ,  Dispatch ,  FlowArrows ,  Global ,  PureDom ,  SVGStyle ,  SVGTransform)->
  Make "SVGActivity", ()->
    root = null
    symbolFns = {}
    
    fetchSymbolFn = (name)->
      symbolFns[name] or symbolFns["default"]
    
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
      instance = fetchSymbolFn(id)(element)
      parent[id] = instance
      parent.children.push instance
      instance.children = []
      instance.element = element
      instance.getElement = ()-> return element
      instance.global = Global
      instance.root = root
      instance.style = SVGStyle element
      instance.transform = SVGTransform element
      setupElement instance, child for child in getChildElements element
    
    
    return activity =
      
      registerInstance: (instanceName, symbolFn)->
        symbolFns[instanceName] = symbolFn
      
      setupSvg: (svg)->
        activity.registerInstance("default", defaultElement)
        root = fetchSymbolFn("root")(svg)
        root.FlowArrows = new FlowArrows()
        root.getElement = ()-> svg
        root.global = Global
        root.root = root
        root.children = []
        setupElement root, child for child in getChildElements svg

        Dispatch root, "setup"
        Dispatch root, "schematicMode"
