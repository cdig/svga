Take ["Registry", "Symbol"], (Registry, Symbol)->
  
  Make "ScopeBuilder", ScopeBuilder = (target, parentScope = null)->
    scope = buildScope target.name, target.elm, parentScope
    for subTarget in target.sub
      ScopeBuilder subTarget, scope
    return scope
  
  
  buildScope = (instanceName, element, parentScope = null)->
    
    symbol = if (s = Symbol.forInstanceName instanceName)?
      s
    else if instanceName?.indexOf("Line") > -1
      Symbol.forSymbolName "HydraulicLine"
    else if instanceName?.indexOf("Field") > -1
      Symbol.forSymbolName "HydraulicField"
    else if instanceName?.indexOf("Mask") > -1
      Symbol.forSymbolName "Mask"
    else
      Symbol.forSymbolName "DefaultElement"
    
    scope = symbol.create element
    element._scope = scope
    scope.element = element
    scope.instanceName = instanceName
    scope.children = []
    scope.parent = parentScope
    scope.root = parentScope?.root or scope
    scope.childName = "child" + (parentScope?.children.length or 0)
    scope.name = instanceName or scope.childName
    
    for scopeProcessor in Registry.all "ScopeProcessor"
      scopeProcessor scope
    
    scope # Composable
