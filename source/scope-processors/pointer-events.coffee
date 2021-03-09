# Depends on style
Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "pointerEvents"

    enabled = true

    accessors =
      get: ()-> enabled
      set: (val)->
        enabled = val
        SVG.style scope.element, "pointer-events", if enabled then null else "none"

    Object.defineProperty scope, "pointerEvents", accessors
