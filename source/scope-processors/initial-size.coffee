Take ["Registry", "ScopeCheck"], (Registry, ScopeCheck)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "initialWidth", "initialHeight"
    
    size = scope.element.getBoundingClientRect()
    scope.initialWidth = size.width
    scope.initialHeight = size.height
