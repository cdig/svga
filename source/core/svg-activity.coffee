Take ["Action", "FlowArrows", "SVGStyle", "SVGTransform", "Symbol", "DOMContentLoaded"],
(      Action ,  FlowArrows ,  SVGStyle ,  SVGTransform ,  Symbol)->
  
  setTimeout ()-> # Allows forward references
    svg = document.rootElement
    root = makeScope "root", svg
    root.FlowArrows = FlowArrows()
    
    # This is useful for other systems that aren't part of the scope tree but that need access to it.
    Make "root", root
    
    Take "SymbolsReady", ()->
      makeScopeTree root, svg
      Action "setup"
      Action "schematicMode"
      setTimeout ()->
        svg.style.opacity = 1
  
  
  makeScope = (instanceName, element, parentScope)->
    symbol = getSymbol instanceName
    addClass element, symbol.name
    instance = symbol.create element
    instance.children ?= []
    instance.element = element # LEGACY
    instance.getElement ?= ()-> element # LEGACY
    instance.root ?= parentScope?.root or instance # If there's no parent, this instance is the root
    instance.style ?= SVGStyle element
    instance.transform ?= SVGTransform element
    if parentScope?
      parentScope[instanceName] = instance if instanceName isnt "DefaultElement"
      parentScope.children.push instance
    instance
  
  
  makeScopeTree = (parentScope, parentElement)->
    for childElement in parentElement.childNodes when childElement instanceof SVGGElement
      childName = childElement.getAttribute("id")?.split("_")[0]
      childScope = makeScope childName, childElement, parentScope
      makeScopeTree childScope, childElement
      
  
  getSymbol = (instanceName)->
    symbol = Symbol.forInstanceName(instanceName)
    if symbol?
      symbol
    else if instanceName?.indexOf("Line") > -1
      Symbol.forSymbolName "HydraulicLine"
    else
      Symbol.forSymbolName "DefaultElement"
  
    
  addClass = (element, newClass)->
    className = element.getAttribute "class"
    # Unfortunately, we can't just use classList in SVG in IE
    element.setAttribute "class", if className? then className + " " + newClass else newClass
