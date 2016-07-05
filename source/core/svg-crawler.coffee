Take "DOMContentLoaded", ()->
  deprecations = ["controlPanel", "ctrlPanel", "navOverlay"]
  
  Make "SVGCrawler", SVGCrawler = (elm)->
    target =
      name: if elm is document.rootElement then "root" else elm.getAttribute("id")?.split("_")[0]
      elm: elm
      sub: []
    
    childNodes = Array.prototype.slice.call elm.childNodes
    
    for childElm in childNodes when childElm instanceof SVGGElement
      if childElm.id in deprecations
        console.log "##{childElm.id} is obsolete. Please remove it from your FLA and re-export this SVG."
        elm.removeChild(childElm)
      else
        target.sub.push SVGCrawler childElm
        
    
    return target
