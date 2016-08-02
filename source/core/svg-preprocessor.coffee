Take ["Scope", "SVG", "Symbol"], (Scope, SVG, Symbol)->
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
        # We make a clone of the use'd element in defs, so that we can reach in and change (eg) strokes/fills.
        defId = childElm.getAttribute "xlink:href"
        def = defs[defId] ?= SVG.defs.querySelector defId
        clone = def.cloneNode true
        elm.replaceChild clone, childElm
        def.parentNode.removeChild def if def.parentNode?
        
        if clone instanceof SVGGElement
          tree.sub.push processElm clone
    
    return tree
  
  
  # BUILD SCOPES ##################################################################################
  
  
  buildScopes = (tree, setups, parentScope = null)->
    symbol = getSymbol(tree.elm) or ()-> {}
    scope = Scope symbol, tree.elm, parent: parentScope
    setups.push scope.setup.bind scope if scope.setup?
    buildScopes subTarget, setups, scope for subTarget in tree.sub
  
  
  getSymbol = (elm)->
    # This is a bit of a legacy hack, where symbols are given names in Flash so that our code can hook up with them.
    baseName = elm.id?.split("_")[0]
    if baseName?.indexOf("Line") > -1
      Symbol.forSymbolName "HydraulicLine"
    else if baseName?.indexOf("Field") > -1
      Symbol.forSymbolName "HydraulicField"
    else
      Symbol.forInstanceName elm.id
  
