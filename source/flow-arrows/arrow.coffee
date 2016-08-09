Take ["FlowArrows:Config", "SVG", "TRS"], (Config, SVG, TRS)->
  Make "FlowArrows:Arrow", (parentElm, segmentData, segmentPosition, vectorPosition, vectorIndex)->
    vector = segmentData.vectors[vectorIndex]
    
    element = TRS SVG.create "g", parentElm
    triangle = SVG.create "polyline", element, points: "0,-16 30,0 0,16"
    line = SVG.create "line", element, x1: -23, y1: 0, x2: 5, y2: 0, "stroke-width": 11, "stroke-linecap": "round"
    
    return arrow =
      update: (parentFlow, parentScale)->
        # if Config.SPACING < 30 * parentScale then throw "Your flow arrows are overlapping. What the devil are you trying? You need to convince Ivan that what you are doing is okay."
        
        vectorPosition += parentFlow
        segmentPosition += parentFlow
        
        while vectorPosition > vector.dist
          vectorIndex++
          if vectorIndex >= segmentData.vectors.length
            vectorIndex = 0
            segmentPosition -= segmentData.dist
          vectorPosition -= vector.dist
          vector = segmentData.vectors[vectorIndex]
        
        while vectorPosition < 0
          vectorIndex--
          if vectorIndex < 0
            vectorIndex = segmentData.vectors.length - 1
            segmentPosition += segmentData.dist
          vector = segmentData.vectors[vectorIndex]
          vectorPosition += vector.dist

        if segmentPosition < segmentData.dist/2
          scale = Math.max 0, Math.min 1, (segmentPosition / segmentData.dist) * segmentData.dist / Config.FADE_LENGTH
        else
          scale = Math.max 0, Math.min 1, 1 - (segmentPosition - (segmentData.dist - Config.FADE_LENGTH)) / Config.FADE_LENGTH
        
        TRS.abs element,
          x: Math.cos(vector.angle) * vectorPosition + vector.x
          y: Math.sin(vector.angle) * vectorPosition + vector.y
          scale: scale * parentScale
          r: vector.angle / (2*Math.PI) + (if parentFlow < 0 then 0.5 else 0)
