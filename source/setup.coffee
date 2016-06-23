Take ["Action", "FlowArrows", "Reaction", "SVGStyle", "SVGTransform", "Symbol", "DOMContentLoaded"],
(      Action ,  FlowArrows ,  Reaction ,  SVGStyle ,  SVGTransform ,  Symbol)->
  
  setTimeout ()->
    svg = document.rootElement
    root = makeScope "root", svg
    root.FlowArrows = FlowArrows()
    
    Take "root", ()->
      makeScopeTree root, svg
      svg.style.transition = "opacity .7s .1s"
      svg.style.opacity = 1
      Action "setup"
      Action "schematicMode"
    
    # This is useful for other systems that aren't part of the scope tree but that need access to it.
    # We also need to wait for all of those systems to be ready before we finish setup.
    Make "root", root
  
  
  makeScope = (instanceName, element, parentScope)->
    symbol = Symbol.forInstanceName(instanceName) or Symbol.forSymbolName("defaultElement")
    addClass element, symbol.name
    instance = symbol.create element
    instance.children ?= []
    instance.element = element # LEGACY
    instance.getElement ?= ()-> element # LEGACY
    instance.root ?= parentScope?.root or instance # If there's no parent, this instance is the root
    instance.style ?= SVGStyle element
    instance.transform ?= SVGTransform element
    if parentScope?
      parentScope[instanceName] = instance if instanceName isnt "defaultElement"
      parentScope.children.push instance
    instance
    
    # We might want to add logic like this somewhere in this function. Not sure.
    # Perhaps lines should be a specific Symbol instead?
    # if element.getAttribute("id")?.indexOf("Line") > -1
    #   addClass element, "dynamicLine"
    #   Reaction "animateMode", ()-> element.removeAttribute "filter"
    #   Reaction "schematicMode", ()-> element.setAttribute "filter", "url(#allblackMatrix)"
  
  
  makeScopeTree = (parentScope, parentElement)->
    for childElement in parentElement.childNodes when childElement instanceof SVGGElement
      childName = childElement.getAttribute("id")?.split("_")[0]
      childScope = makeScope childName, childElement, parentScope
      makeScopeTree childScope, childElement
      

  
  addClass = (element, newClass)->
    className = element.getAttribute "class"
    # Unfortunately, we can't just use classList in SVG in IE
    element.setAttribute "class", if className is "" then newClass else className + " " + newClass
