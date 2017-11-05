# This processor depends on the Style processor

Take ["Registry", "ScopeCheck", "Tween"], (Registry, ScopeCheck, Tween)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "show", "hide"
    
    tick = (v)-> scope.alpha = v
    scope.show = (duration = 1, target = 1)-> Tween scope.alpha, target, duration, tick:tick, ease:"linear"
    scope.hide = (duration = 1, target = 0)-> Tween scope.alpha, target, duration, tick:tick, ease:"linear"
