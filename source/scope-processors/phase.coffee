Take ["AC", "Registry", "ScopeCheck", "SVG"], (AC, Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "ac"

    ac = {}

    Object.defineProperties ac,
      phase:
        get: -> ac._phase ?= 0
        set: (val) ->
          if val isnt ac._phase
            ac._phase = val
            if scope._setColor?
              scope._setColor AC ac._phase, ac._voltage
            else
              scope.fill = Pressure scope.pressure
      voltage:
        get: -> ac._voltage ?= 0
        set: (val) ->
          if val isnt ac._voltage
            ac._voltage = val
            if scope._setColor?
              scope._setColor AC ac._phase, ac._voltage
            else
              scope.fill = Pressure scope.pressure

    Object.defineProperty scope, "ac",
      get: -> ac
      set: (val) ->
        ac.phase = val.phase if val?.phase?
        ac.voltage = val.voltage if val?.voltage?