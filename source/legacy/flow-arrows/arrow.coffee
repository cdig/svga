Take ["FlowArrows:Config", "SVG", "TRS"], (Config, SVG, TRS)->
  Make "FlowArrows:Arrow", (target, segment, segmentPosition, edgePosition, edgeIndex)->
    edge = segment.edges[edgeIndex]
    
    element = TRS SVG.create "g", target
    triangle = SVG.create "polyline", element, points: "0,-16 30,0 0,16"
    line = SVG.create "line", element, x1: -23, y1: 0, x2: 5, y2: 0, "stroke-width": 11, "stroke-linecap": "round"
    
    return arrow =
      update: (velocity, ancestorScale)->
        edgePosition += velocity
        segmentPosition += velocity
        
        while edgePosition > edge.length
          edgePosition -= edge.length
          edgeIndex++
          if edgeIndex >= segment.edges.length
            edgeIndex = 0
            segmentPosition -= segment.length
          edge = segment.edges[edgeIndex]
        
        while edgePosition < 0
          edgeIndex--
          edgeIndex = segment.edges.length - 1 if edgeIndex < 0
          edge = segment.edges[edgeIndex]
          edgePosition += edge.length
        
        # firstHalf = edgePosition < segment.length/2
        scale = 1
        #
        # if fadeStart
        #   scale = Math.max 0, Math.min 1, (edgePosition / edge.length) * edge.length / Config.FADE_LENGTH
        # else if fadeEnd
        #   scale = Math.max 0, Math.min 1, 1 - (edgePosition - (edge.length - Config.FADE_LENGTH))/Config.FADE_LENGTH
        
        TRS.abs element,
          x: Math.cos edge.angle * edgePosition + edge.x
          y: Math.sin edge.angle * edgePosition + edge.y
          scale: scale * ancestorScale
          r: edge.angle / (2*Math.PI) + (if velocity < 0 then 0.5 else 0)
