Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "dash"
    
    paths = scope.element.querySelectorAll "path"
    
    scope.dash = (v)->
      for path in paths
        SVG.attrs path, "stroke-dasharray": v
        
    scope.dash.manifold = ()-> scope.dash "6 3 12 3"
    scope.dash.pilot = ()-> scope.dash "6 6"
      
