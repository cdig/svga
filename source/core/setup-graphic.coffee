Take [], ()->
  
  setupColorMatrix = (defs, name, matrixValue)->
    filter = document.createElementNS "http://www.w3.org/2000/svg", "filter"
    filter.setAttribute "id", name
    colorMatrix = document.createElementNS "http://www.w3.org/2000/svg", "feColorMatrix"
    colorMatrix.setAttribute "in", "SourceGraphic"
    colorMatrix.setAttribute "type", "matrix"
    colorMatrix.setAttribute "values", matrixValue
    filter.appendChild colorMatrix
    defs.appendChild filter
  
  
  Make "SetupGraphic", (svg)->
    defs = svg.querySelector "defs"
    
    setupColorMatrix defs, "highlightMatrix", ".5  0   0    0   0
                                               .5  1   .5   0  20
                                               0   0   .5   0   0
                                               0   0   0    1   0"

    setupColorMatrix defs, "greyscaleMatrix", ".33 .33 .33  0   0
                                               .33 .33 .33  0   0
                                               .33 .33 .33  0   0
                                               0   0   0    1   0"

    setupColorMatrix defs, "allblackMatrix",  "0   0   0    0   0
                                               0   0   0    0   0
                                               0   0   0    0   0
                                               0   0   0    1   0"
    
    svg # Pass through
