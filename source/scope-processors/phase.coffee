# Depends on style
Take ["Phase", "Registry", "ScopeCheck", "SVG"], (Phase, Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "phase"

    phase = null

    accessors =
      get: ()-> phase
      set: (val)->
        if phase isnt val
          scope.stroke = Phase val
          console.log Phase val

    Object.defineProperty scope, "phase", accessors
