do ()->
  Make "SVGCrawler", SVGCrawler = (elm)->
    name = if elm is document.rootElement then "root" else elm.getAttribute("id")?.split("_")[0]
    
    target =
      name: name
      elm: elm
      sub: []
    
    childNodes = Array.prototype.slice.call elm.childNodes
    
    for childElm in childNodes when childElm instanceof SVGGElement
      target.sub.push SVGCrawler childElm
        
    
    return target
