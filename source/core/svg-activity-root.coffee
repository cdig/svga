do ()->
  Take ["defaultElement", "PureDom","FlowArrows", "SVGControlPanel","SVGTransform", "SVGStyle", "load"], (defaultElement, PureDom, FlowArrows, SVGControlPanel, SVGTransform, SVGStyle)->
    setupInstance = (instance)->
      for child in instance.children
        setupInstance(child)
      instance.setup()
    setupColorMatrix = (defs, name, matrixValue)->
      filter = document.createElementNS("http://www.w3.org/2000/svg", "filter")
      filter.setAttribute("id", name)
      colorMatrix = document.createElementNS("http://www.w3.org/2000/svg", "feColorMatrix")
      colorMatrix.setAttribute("in", "SourceGraphic")
      colorMatrix.setAttribute("type", "matrix")
      colorMatrix.setAttribute("values", matrixValue)

      filter.appendChild(colorMatrix)
      defs.appendChild(filter)


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

        registerControl: (controlName)->

        setupDocument: (activityName, contentDocument)->
          scope.registerInstance("default", defaultElement)
          scope.root = scope.instances["root"](contentDocument)
          scope.root.FlowArrows = new FlowArrows()
          scope.root.root = scope.root

          scope.root.getElement = ()->
            return contentDocument
          defs = contentDocument.querySelector("defs")
          setupColorMatrix(defs, "highlightMatrix", "0.5 0.0 0.0 0.0 00
               0.5 1.0 0.5 0.0 20
               0.0 0.0 0.5 0.0 00
               0.0 0.0 0.0 1.0 00" )
          setupColorMatrix(defs, "greyscaleMatrix", "0.33 0.33 0.33 0.0 0
             0.33 0.33 0.33 0.0 0
             0.33 0.33 0.33 0.0 0
             0.0 0.0 0.0 1.0 0")
          setupColorMatrix(defs, "allblackMatrix", "0 0.0 0.0 0.0 0
             0.0 0.0 0.0 0.0 0
             0.0 0.0 0.0 0.0 0
             0.0 0.0 0.0 1.0 0" )
          childElements = getChildElements(contentDocument)
          scope.root.children = []
          for child in childElements
            scope.setupElement(scope.root, child)

          if scope.root.controlPanel
            scope.root._controls = new SVGControlPanel(scope.root, scope.root.controlPanel)
            scope.root._controls.setup()
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
          parent[id].getElement = ()->
            return element


          childElements = getChildElements(element)
          for child in childElements
            scope.setupElement(parent[id], child)











