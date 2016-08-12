# Depends on style

Take ["Pressure", "Registry", "ScopeCheck", "SVG"], (Pressure, Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "pressure"
    
    isLine = scope._symbol?.symbolName is "HydraulicLine"
    pressure = null
    
    Object.defineProperty scope, 'pressure',
      get: ()-> pressure
      set: (val)->
        if pressure isnt val
          pressure = val
          if isLine
            scope.setHydraulicLinePressure pressure
          else
            scope.fill = Pressure scope.pressure
