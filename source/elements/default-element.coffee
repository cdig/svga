Take ["Symbol"], (Symbol)->
  Symbol "defaultElement", [], (svgElement)->
    textElement = svgElement.querySelector("text")?.querySelector("tspan")
    
    return scope =
      setText: (text)->
        textElement?.textContent = text
