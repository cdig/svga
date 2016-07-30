Take ["Scope", "SVG"], (Scope, SVG)->
  deprecations = ["controlPanel", "ctrlPanel", "navOverlay"]
  defs = {}
  
  
  Make "SVGPreprocessor", SVGPreprocessor =
    crawl: (elm)->
      tree = processElm elm
      defs = null # Avoid dangling references
      return tree
    
    build: (tree)->
      buildScopes tree, setups = []
      setup() for setup in setups by -1 # loop backwards, to set up children before parents
  
  
  buildScopes = (tree, setups, parentScope = null)->
    scope = Scope tree.elm, parentScope
    setups.push scope.setup.bind(scope) if scope.setup?
    buildScopes subTarget, setups, scope for subTarget in tree.sub

  
  processElm = (elm)->
    tree =
      elm: elm
      sub: []
    
    childNodes = Array.prototype.slice.call elm.childNodes
    
    for childElm in childNodes
      
      if (childElm.id in deprecations) or childElm.id?.indexOf("Mask") > -1
        console.log "##{childElm.id} is obsolete. Please remove it from your FLA and re-export this SVG."
        elm.removeChild childElm

      else if childElm instanceof SVGGElement
        tree.sub.push processElm childElm

      else if childElm instanceof SVGUseElement
        defId = childElm.getAttribute "xlink:href"
        def = defs[defId] ?= SVG.defs.querySelector defId
        clone = def.cloneNode true
        elm.replaceChild clone, childElm
        def.parentNode.removeChild def if def.parentNode?
        
        if clone instanceof SVGGElement
          tree.sub.push processElm clone
    
    return tree
