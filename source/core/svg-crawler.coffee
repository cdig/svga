Take "DOMContentLoaded", ()->
  Make "SVGCrawler", SVGCrawler = (elm)->
    target =
      name: if elm is document.rootElement then "root" else elm.getAttribute("id")?.split("_")[0]
      elm: elm
      sub: []
    
    childNodes = Array.prototype.slice.call elm.childNodes
    
    for childElm in childNodes when childElm instanceof SVGGElement
      target.sub.push SVGCrawler childElm
        
    
    return target
