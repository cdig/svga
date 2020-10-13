Take ["Registry", "ScopeCheck"], (Registry, ScopeCheck)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "initialWidth", "initialHeight"

    size = scope.element.getBBox() # Note: Changed on 2020-09-29 from getBoundingClientRect
    scope.initialWidth = size.width
    scope.initialHeight = size.height
