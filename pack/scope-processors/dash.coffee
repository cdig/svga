Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "dash"
    
    paths = scope.element.querySelectorAll "path"
    
    scope.dash = (v)->
      for path in paths
        SVG.attrs path, "stroke-dasharray": v
        
    scope.dash.manifold = ()-> scope.dash "50 5 10 5 10 5"
    scope.dash.pilot = ()-> scope.dash "6 6"
      
