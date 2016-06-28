Take ["Action", "FlowArrows", "SVGStyle", "SVGTransform", "SVG", "Symbol", "DOMContentLoaded"],
(      Action ,  FlowArrows ,  SVGStyle ,  SVGTransform ,  SVG ,  Symbol)->
  
  makeScope = (instanceName, element, parentScope)->
    symbol = getSymbol instanceName
    console.log Object.assign {}, Take()
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
  
  Take "SymbolsReady", ()->
    setTimeout ()-> # Wait for the second wave of symbols
      svg = document.rootElement
      root = makeScope "root", svg
      root.FlowArrows = FlowArrows()
      
      # This is useful for other systems that aren't part of the scope tree but that need access to it.
      Make "root", root
    
      makeScopeTree root, svg
      Action "setup"
      setTimeout ()-> # Wait for setup to finish
        Action "Schematic:Show"
        setTimeout ()-> # Wait for Schematic:Show to finish
          svg.style.opacity = 1
