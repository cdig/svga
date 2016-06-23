# We wait for SymbolsReady so that we don't trigger it ourselves, prematurely
Take ["Symbol", "SymbolsReady"], (Symbol)->
  Symbol "DefaultElement", [], (svgElement)->
    textElement = svgElement.querySelector("text")?.querySelector("tspan")
    
    return scope =
      setText: (text)->
        textElement?.textContent = text
