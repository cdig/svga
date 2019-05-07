# Depends on style
Take ["Voltage", "Registry", "ScopeCheck", "SVG"], (Voltage, Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "voltage"

    voltage = null

    accessors =
      get: ()-> voltage
      set: (val)->
        if voltage isnt val
          voltage = val
          if scope._setColor?
            scope._setColor voltage
          else
            scope.fill = Voltage scope.voltage

    Object.defineProperty scope, "voltage", accessors
