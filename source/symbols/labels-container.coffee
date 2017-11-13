Take ["Reaction", "Symbol", "SVG"], (Reaction, Symbol, SVG)->
  Symbol "Labels", ["labelsContainer"], (svgElement)->
    return scope =
      setup: ()->
        Reaction "Labels:Hide", ()-> scope.alpha = false
        Reaction "Labels:Show", ()-> scope.alpha = true
        Reaction "Background:Set", (v)->
          l = v.split(", ")[2]?.split("%")[0]
          l /= 100
          l = (l/2 + .8) % 1
          
          for c in svgElement.querySelectorAll "[fill]"
            current = SVG.attr c, "fill"
            if current isnt "none" and current isnt "transparent"
              SVG.attr c, "fill", "hsl(227, 4%, #{l*100}%)"
          
          for c in svgElement.querySelectorAll "[stroke]"
            current = SVG.attr c, "stroke"
            if current isnt "none" and current isnt "transparent"
              SVG.attr c, "stroke", "hsl(227, 4%, #{l*100}%)"
  
