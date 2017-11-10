Take ["Reaction", "Symbol", "SVG"], (Reaction, Symbol, SVG)->
  Symbol "Labels", ["labelsContainer"], (svgElement)->
    for c in svgElement.querySelectorAll "[fill]"
      c.removeAttributeNS null, "fill"
    
    for c in svgElement.querySelectorAll "[stroke]"
      c.removeAttributeNS null, "stroke"
    
    return scope =
      setup: ()->
        Reaction "Labels:Hide", ()-> scope.alpha = false
        Reaction "Labels:Show", ()-> scope.alpha = true
        Reaction "Background:Set", (v)->
          l = v.split(", ")[2]?.split("%")[0]
          l /= 100
          l = (l/2 + .8) % 1
          SVG.attr svgElement, "fill", "hsl(227, 4%, #{l*100}%)"
          SVG.attr svgElement, "stroke", "hsl(227, 4%, #{l*100}%)"
