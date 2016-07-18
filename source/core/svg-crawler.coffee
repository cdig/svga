Take ["SVG", "DOMContentLoaded"], (SVG)->
  deprecations = ["controlPanel", "ctrlPanel", "navOverlay"]
  
  Make "SVGCrawler", SVGCrawler = (elm)->
    target =
      name: elm.getAttribute("id")?.split("_")[0]
      elm: elm
      sub: []
    
    childNodes = Array.prototype.slice.call elm.childNodes
    
    for childElm in childNodes
      if childElm.id in deprecations
        console.log "##{childElm.id} is obsolete. Please remove it from your FLA and re-export this SVG."
        elm.removeChild(childElm)
      else if childElm instanceof SVGGElement
        target.sub.push SVGCrawler childElm
      else if childElm instanceof SVGUseElement
        useParent = childElm.parentNode
        link = SVG.defs.querySelector childElm.getAttribute "xlink:href"
        clone = link.cloneNode true
        useParent.replaceChild clone, childElm
    
    return target
