Take ["SVG"], (SVG)->
  deprecations = ["controlPanel", "ctrlPanel", "navOverlay"]
  
  defs = {}
  
  Make "SVGCrawler", SVGCrawler = (elm)->
    target =
      elm: elm
      sub: []
    
    childNodes = Array.prototype.slice.call elm.childNodes
    
    for childElm in childNodes

      if childElm.id in deprecations
        console.log "##{childElm.id} is obsolete. Please remove it from your FLA and re-export this SVG."
        elm.removeChild childElm

      else if childElm instanceof SVGGElement
        target.sub.push SVGCrawler childElm

      else if childElm instanceof SVGUseElement
        defId = childElm.getAttribute "xlink:href"
        def = defs[defId] ?= SVG.defs.querySelector defId
        clone = def.cloneNode true
        elm.replaceChild clone, childElm
        def.parentNode.removeChild def if def.parentNode?
        
        if clone instanceof SVGGElement
          target.sub.push SVGCrawler clone
    
    return target
