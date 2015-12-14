do ->
  Make "defaultElement", defaultElement = (svgElement)->
    return scope = 
      setup: ()->

      setText: (text)->
        textElement = svgElement.querySelector("text").querySelector("tspan")
        if textElement?
          textElement.textContent=text

      animate: (dT, time)->
        

