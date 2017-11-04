# This is a special scope processor just for controls,
# allowing them to be enabled and disabled by animation code.

Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope, props)->
    
    return unless props._isControl
    
    ScopeCheck scope, "enabled"
    
    enabled = true
    
    Object.defineProperty scope, 'enabled',
      get: ()-> enabled
      set: (val)->
        if enabled isnt val
          enabled = val
          scope.input?.enable enabled
          console.log scope.input
          if enabled
            scope.alpha = 1
            SVG.attrs scope.element, disabled: null
          else
            scope.alpha = 0.3
            SVG.attrs scope.element, disabled: ""
    
    scope.enabled = false if props.enabled is false
