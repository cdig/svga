Take ["Style","Symbol","Transform"],
(      Style , Symbol , Transform )->
  processors = []
  tooLate = false
  
  ScopeBuilder = (target, parentScope = null)->
    tooLate = true
    scope = buildScope target.name, target.elm, parentScope
    ScopeBuilder subTarget, scope for subTarget in target.sub
    return scope
  
  ScopeBuilder.process = (fn)->
    if tooLate then console.log fn; throw "^ ScopeBuilder.process fn was too late. Please make it init faster."
    processors.push fn
  
  Make "ScopeBuilder", ScopeBuilder
  
  
  buildScope = (instanceName, element, parentScope = null)->
    symbol = getSymbol instanceName
    scope = symbol.create element
    
    scope.children ?= []
    scope.element ?= element
    Object.defineProperty scope, "FlowArrows", get: ()-> throw "root.FlowArrows has been removed. Please use SVGA.arrows instead."
    scope.getElement ?= ()-> throw "@getElement() has been removed. Please use @element instead."
    Style scope
    Transform scope
    fn scope for fn in processors
    
    if not parentScope? # If there's no parent, this scope is the root
      scope.root ?= scope
    else
      scope.root ?= parentScope.root
      parentScope[instanceName] ?= scope if instanceName isnt "DefaultElement"
      parentScope.children.push scope
    
    scope # Composable
  
  
  getSymbol = (instanceName)->
    if symbol = Symbol.forInstanceName instanceName
      symbol
    else if instanceName?.indexOf("Line") > -1
      Symbol.forSymbolName "HydraulicLine"
    else if instanceName?.indexOf("Field") > -1
      Symbol.forSymbolName "HydraulicField"
    else
      Symbol.forSymbolName "DefaultElement"
