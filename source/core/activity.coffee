# Wait for "load" to give all the Symbols a chance to execute
Take ["Action", "FlowArrows", "SVGStyle", "SVGTransform", "SVG", "Symbol", "load"],
(      Action ,  FlowArrows ,  SVGStyle ,  SVGTransform ,  SVG ,  Symbol)->
  
  makeScope = (instanceName, element, parentScope)->
    symbol = getSymbol instanceName
    addClass element, symbol.name
    scope = symbol.create element
    scope.children ?= []
    scope.element = element # LEGACY
    scope.getElement ?= ()-> element # LEGACY
    scope.root ?= parentScope?.root or scope # If there's no parent, this scope is the root
    scope.style ?= SVGStyle element
    scope.transform ?= SVGTransform element
    if parentScope?
      parentScope[instanceName] = scope if instanceName isnt "DefaultElement"
      parentScope.children.push scope
    scope
  
  
  makeScopeTree = (parentScope, parentElement)->
    for childElement in parentElement.childNodes
      if childElement instanceof SVGGElement # Only set up <g> elements
        if not childElement._SVG? # Don't set up generated elements
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
    SVG.attr element, "class", if className? then className + " " + newClass else newClass
  
  
  # Begin Setup
  
  setTimeout ()-> # Give Symbols a bit more time to be defined, since some of them might be waiting on Take()s
    svg = document.rootElement
    root = makeScope "root", svg
    
    # This is useful for other systems that aren't part of the scope tree but that need access to it.
    Make "root", root

    makeScopeTree root, svg
    Action "setup"
    setTimeout ()-> # Wait for setup to finish
      Action "Schematic:Show"
      setTimeout ()-> # Wait for Schematic:Show to finish
        svg.style.opacity = 1
