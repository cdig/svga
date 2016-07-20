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
      symbol = Symbol.forSymbolName "HydraulicLine"
    else if strippedName?.indexOf("Field") > -1
      symbol = Symbol.forSymbolName "HydraulicField"
    else if strippedName?.indexOf("Mask") > -1
      symbol = Symbol.forSymbolName "Mask"
    else
      symbol = Symbol.forSymbolName "DefaultElement"
    
    # Create the scope and add basic properties
    scope = symbol.create element
    element._scope = scope
    scope.element = element
    scope.children = []
    scope.parent = parentScope
    scope.root = parentScope?.root or scope
    scope.childName = "child" + (parentScope?.children.length or 0)
    scope.name = instanceName or strippedName or scope.childName
    
    # Run this scope through all the processors, which add special properties, callbacks, and other fanciness
    for scopeProcessor in Registry.all "ScopeProcessor"
      scopeProcessor scope
    
    # Build child scopes
    for subTarget in target.sub
      ScopeBuilder subTarget, scope
