Take ["Animation","FlowArrows","Style","Symbol","Transform"],
(      Animation , FlowArrows , Style , Symbol , Transform )->
  
  Make "ScopeBuilder", ScopeBuilder = (target, parentScope = null)->
    scope = buildScope target.name, target.elm, parentScope
    ScopeBuilder subTarget, scope for subTarget in target.sub
    return scope
  
  
  buildScope = (instanceName, element, parentScope = null)->
    symbol = getSymbol instanceName
    scope = symbol.create element
    scope.children ?= []
    scope.element ?= element
    Object.defineProperty scope, "FlowArrows", get: ()-> throw "root.FlowArrows has been removed. Please use SVGA.arrows instead."
    scope.getElement ?= ()-> throw "scope.getElement() has been removed. Please use scope.element instead."
    Style scope
    Transform scope
    Animation scope
    
    if not parentScope? # If there's no parent, this scope is the root
      scope.root ?= scope
    else
      scope.root ?= parentScope.root
      parentScope[instanceName] ?= scope if instanceName isnt "DefaultElement"
      parentScope.children.push scope
    
    scope
  
  
  getSymbol = (instanceName)->
    if symbol = Symbol.forInstanceName instanceName
      symbol
    else if instanceName?.indexOf("Line") > -1
      Symbol.forSymbolName "HydraulicLine"
    else
      Symbol.forSymbolName "DefaultElement"
