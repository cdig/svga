Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "stroke", "fill"
    
    childPathStroke = childPathFill = scope.element.querySelector "path"
    
    stroke = null
    Object.defineProperty scope, 'stroke',
      get: ()-> stroke
      set: (val)->
        if stroke isnt val
          SVG.attr scope.element, "stroke", stroke = val
          if childPathStroke?
            SVG.attr childPathStroke, "stroke", null
            childPathStroke = null
    
    
    fill = null
    Object.defineProperty scope, 'fill',
      get: ()-> fill
      set: (val)->
        if fill isnt val
          SVG.attr scope.element, "fill", fill = val
          if childPathFill?
            SVG.attr childPathFill, "fill", null
            childPathFill = null
