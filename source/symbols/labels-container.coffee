Take ["Reaction","Symbol","SVG"], (Reaction, Symbol, SVG)->
  Symbol "Labels", [], (svgElement)->
    for c in svgElement.querySelectorAll "[fill]"
      c.removeAttributeNS null, "fill"
    
    return scope =
      setup: ()->
        Reaction "Labels:Hide", ()-> scope.visible = false
        Reaction "Labels:Show", ()-> scope.visible = true
        Reaction "Background:Set", (v)->
          l = (v/2 + .8) % 1
          SVG.attr svgElement, "fill", "hsl(220, 4%, #{l*100}%)"
            
