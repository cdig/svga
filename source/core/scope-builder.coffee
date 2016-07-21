Take ["Registry", "Symbol"], (Registry, Symbol)->
  Make "ScopeBuilder", ScopeBuilder = (target, parentScope = null)->
    
    element = target.elm
    strippedName = element.id?.split("_")[0]
    symbolForInstanceName = Symbol.forInstanceName element.id
    
    # Figure out which Symbol we should use to create the scope
    if symbolForInstanceName?
      instanceName = element.id
      symbol = symbolForInstanceName
    else if strippedName?.indexOf("Line") > -1
      symbolName = "HydraulicLine"
      symbol = Symbol.forSymbolName symbolName
    else if strippedName?.indexOf("Field") > -1
      symbolName = "HydraulicField"
      symbol = Symbol.forSymbolName symbolName
    else if strippedName?.indexOf("Mask") > -1
      symbolName = "Mask"
      symbol = Symbol.forSymbolName symbolName
    else
      symbolName = "DefaultElement"
      symbol = Symbol.forSymbolName symbolName
    
    # Create the scope and add basic properties
    scope = symbol.create element
    element._scope = scope
    scope.element = element
    scope.children = []
    scope.parent = parentScope
    scope.root = parentScope?.root or scope
    scope.childName = "child" + (parentScope?.children.length or 0)
    scope.instanceName = instanceName or strippedName or scope.childName
    
    # Add the "scope-name" attribute to the element
    element.setAttribute "scope-name", scope.instanceName
    
    # Sort all attributes so that scope-name comes first
    attrs = Array.prototype.slice.call element.attributes
    for attr in attrs
      if attr.name isnt "scope-name"
        element.removeAttributeNS attr.namespaceURI, attr.name
        element.setAttributeNS attr.namespaceURI, attr.name, attr.value
    
    # Run this scope through all the processors, which add special properties, callbacks, and other fanciness
    for scopeProcessor in Registry.all "ScopeProcessor"
      scopeProcessor scope

    # Build child scopes
    for subTarget in target.sub
      ScopeBuilder subTarget, scope
