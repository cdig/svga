Take ["ScopeBuilder"], (ScopeBuilder)->
  Make "SVGCrawler", SVGCrawler =
    
    preprocessSVG: (elm)->
      target =
        elm: elm
        sub: []
      
      for childElm in elm.childNodes
        if childElm instanceof SVGGElement
          target.sub.push SVGCrawler.preprocessSVG childElm
        else if childElm instanceof SVGUseElement
          null # Inline. Recurse?
      
      return target
    
    
    buildScopes: (target, parentScope = null)->
      name = target.elm.getAttribute("id")?.split("_")[0]
      scope = ScopeBuilder name, target.elm, parentScope
      SVGCrawler.buildScopes subTarget, scope for subTarget in target.sub
