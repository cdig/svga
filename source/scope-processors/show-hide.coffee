# This processor depends on the Style processor

Take ["Registry", "ScopeCheck", "Tween"], (Registry, ScopeCheck, Tween)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "show", "hide"
    
    tick = (v)-> scope.alpha = v
    scope.show = (d = 1)-> Tween scope.alpha, 1, d, tick
    scope.hide = (d = 1)-> Tween scope.alpha, -1, d, tick
