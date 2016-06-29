Take ["Symbol"], (Symbol)->
  Symbol "DefaultElement", [], (svgElement)->
    textElement = svgElement.querySelector("text")?.querySelector("tspan")
    
    return scope =
      setText: (text)->
        textElement?.textContent = text
