Take ["Registry", "Style", "Symbol", "Transform"], (Registry, Style, Symbol, Transform)->
  
  ScopeBuilder = (target, parentScope = null)->
    scope = buildScope target.name, target.elm, parentScope
    ScopeBuilder subTarget, scope for subTarget in target.sub
    return scope
  
  ScopeBuilder.process = (fn)->
    Registry.add "ScopeBuilder", fn
  
  Make "ScopeBuilder", ScopeBuilder
  
  
  buildScope = (instanceName, element, parentScope = null)->
    symbol = getSymbol instanceName
    scope = symbol.create element
    
    element._scope = scope
    
    scope.children ?= []
    scope.element ?= element
    scope.parent ?= parentScope
    Object.defineProperty scope, "FlowArrows", get: ()-> throw "root.FlowArrows has been removed. Please use FlowArrows instead."
    scope.getElement ?= ()-> throw "@getElement() has been removed. Please use @element instead."
    Style scope
    Transform scope
    fn scope for fn in Registry.all "ScopeBuilder"
    
    if parentScope?
      scope.root ?= parentScope.root
      
      name = if instanceName? and instanceName isnt "DefaultElement"
        instanceName
      else
        "child" + parentScope.children.length
      
      if not element.getAttributeNS(null, "class")?
        element.setAttributeNS null, "class", name
            
      throw "Duplicate instance name detected in #{parentScope.name}: #{name}" if parentScope[name]?
      parentScope[name] = scope
      parentScope.children.push scope
      
      # These help debugging
      scope.instanceName = instanceName
      scope.name = name
        
    else # If there's no parent, this scope is the root
      scope.root ?= scope
    
    scope # Composable
  
  
  getSymbol = (instanceName)->
    if symbol = Symbol.forInstanceName instanceName
      symbol
    else if instanceName?.indexOf("Line") > -1
      Symbol.forSymbolName "HydraulicLine"
    else if instanceName?.indexOf("Field") > -1
      Symbol.forSymbolName "HydraulicField"
    else if instanceName?.indexOf("Mask") > -1
      Symbol.forSymbolName "Mask"
    else
      Symbol.forSymbolName "DefaultElement"
