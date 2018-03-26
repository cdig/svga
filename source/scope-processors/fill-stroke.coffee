Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "stroke", "strokeWidth", "fill"
    
    childPathStrokes = childPathStrokeWidths = childPathFills = scope.element.querySelectorAll "path"
    
    stroke = null
    Object.defineProperty scope, 'stroke',
      get: ()-> stroke
      set: (val)->
        if stroke isnt val
          SVG.attr scope.element, "stroke", stroke = val
          if childPathStrokes.length > 0
            SVG.attr childPathStroke, "stroke", null for childPathStroke in childPathStrokes
            childPathStrokes = []


    strokeWidth = null
    Object.defineProperty scope, 'strokeWidth',
      get: ()-> strokeWidth
      set: (val)->
        if strokeWidth isnt val
          SVG.attr scope.element, "strokeWidth", strokeWidth = val
          if childPathStrokeWidths.length > 0
            SVG.attr childPathStrokeWidth, "strokeWidth", null for childPathStrokeWidth in childPathStrokeWidths
            childPathStrokeWidths = []

    
    fill = null
    Object.defineProperty scope, 'fill',
      get: ()-> fill
      set: (val)->
        if fill isnt val
          SVG.attr scope.element, "fill", fill = val
          if childPathFills.length > 0
            SVG.attr childPathFill, "fill", null for childPathFill in childPathFills
            childPathFills = []
