do ()-> 
  Take ["defaultElement","FlowArrows", "PureDom", "SVGActivities", "SVGTransform", "SVGStyle" ], (defaultElement, FlowArrows, PureDom, SVGActivities, SVGTransform, SVGStyle)-> 
    setupInstance = (instance)->
      for child in instance.children
        setupInstance(child)
      instance.setup()
    setupHighlighter = (defs)->
      highlighter = document.createElementNS("http://www.w3.org/2000/svg", "filter")
      highlighter.setAttribute("id", "highlightMatrix")
      colorMatrix = document.createElementNS("http://www.w3.org/2000/svg", "feColorMatrix")
      colorMatrix.setAttribute("in", "SourceGraphic")
      colorMatrix.setAttribute("type", "matrix")
      colorMatrix.setAttribute("values","0.5 0.0 0.0 0.0 00
               0.5 1.0 0.5 0.0 20
               0.0 0.0 0.5 0.0 00
               0.0 0.0 0.0 1.0 00" )
      highlighter.appendChild(colorMatrix)
      defs.appendChild(highlighter)

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

    Make "SVGActivity", SVGActivity = ()->
      return scope = 
        functions: {}
        instances: {}
        root: null 

        registerInstance: (instanceName, instance)->
          scope.instances[instanceName] = instance

        setupDocument: (activityName, contentDocument)->
          console.log scope.root
          scope.registerInstance("default", defaultElement)
          scope.root = scope.instances["root"](contentDocument)
          scope.root.FlowArrows = new FlowArrows()
          console.log scope.root
          setupHighlighter(contentDocument.querySelector("defs"))
          SVGActivities.registerActivity(activityName, scope.root)
          childElements = getChildElements(contentDocument)
          scope.root.children = []
          for child in childElements
            scope.setupElement(scope.root, child)
           setupInstance(scope.root)

        getRootElement: ()->
          return scope.root.getRootElement()
          
        setupElement: (parent, element)->
          id = element.getAttribute("id")
          id = id.split("_")[0]
          instance = scope.instances[id]
          if not instance?
            instance = scope.instances["default"]
            
          parent[id] = instance(element)
          parent[id].transform = SVGTransform(element)
          parent[id].transform.setup()
          parent[id].style = SVGStyle(element)
          parent.children.push parent[id]
          parent[id].children = []
          parent[id].root = scope.root

          
          childElements = getChildElements(element)
          for child in childElements
            scope.setupElement(parent[id], child)

           



