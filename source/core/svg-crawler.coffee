do ()->
  Make "SVGCrawler", SVGCrawler = (elm)->
    name = if elm is document.rootElement then "root" else elm.getAttribute("id")?.split("_")[0]
    
    target =
      name: name
      elm: elm
      sub: []
    
    for childElm in elm.childNodes
      if childElm instanceof SVGGElement
        target.sub.push SVGCrawler childElm
      else if childElm instanceof SVGUseElement
        null # Inline. Recurse?
    
    return target
