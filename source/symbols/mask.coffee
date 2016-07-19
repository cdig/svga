Take ["SVG", "Symbol"], (SVG, Symbol)->
  Symbol "Mask", [], (svgElement)->
    svgElement.parentNode.removeChild svgElement
    return scope = {}
