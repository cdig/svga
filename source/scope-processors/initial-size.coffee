Take ["Config", "Registry", "ScopeCheck"], (Config, Registry, ScopeCheck)->
  return if Config.skipInitialSize # This is a workaround for a bug in Chrome Canary
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "initialWidth", "initialHeight"

    size = scope.element.getBBox() # Note: Changed on 2020-09-29 from getBoundingClientRect
    scope.initialWidth = size.width
    scope.initialHeight = size.height
