do ->
  Make "defaultElement", defaultElement = (svgElement)->
    return scope = 
      setup: ()->
          
      getElement: ()->
        return svgElement

      setText: (text)->
        textElement = svgElement.querySelector("text").querySelector("tspan")
        if textElement?
          textElement.textContent=text

      animate: (dT, time)->
        

