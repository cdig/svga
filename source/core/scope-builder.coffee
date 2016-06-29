Take ["Style","SVGA","Symbol","Transform"],
(      Style , SVGA , Symbol , Transform )->
  
  getSymbol = (instanceName)->
    if symbol = Symbol.forInstanceName instanceName
      symbol
    else if instanceName?.indexOf("Line") > -1
      Symbol.forSymbolName "HydraulicLine"
    else
      Symbol.forSymbolName "DefaultElement"
  
  
  Make "ScopeBuilder", (instanceName, element, parentScope = null)->
    symbol = getSymbol instanceName
    scope = symbol.create element
    scope.children ?= []
    scope.element ?= element # LEGACY
    scope.getElement ?= ()-> element # LEGACY
    scope.style ?= Style element
    scope.transform ?= Transform element
    
    if not parentScope? # If there's no parent, this scope is the root
      scope.FlowArrows ?= SVGA.arrows # LEGACY
      scope.root ?= scope
    else
      scope.root ?= parentScope.root
      parentScope[instanceName] = scope if instanceName isnt "DefaultElement"
      parentScope.children.push scope
    
    scope
