do ->
  edgesToLines = (edgesData)->
    linesData = [] 
    edge = []
    for i in [0..edgesData.length-1]
      edge = edgesData[i]
      linesData.push(edge[0], edge[2])
      
    return linesData

  formSegments = (lineData, flowArrows)->
    segments = [] # array of segments
    segmentEdges = null # array of edges in the current segment

    # loop in pairs, since lineData is alternating start/end points of edges
    for i in [0..lineData.length - 1] by 2  
      pointA = lineData[i]
      pointB = lineData[i+1]

      # if we're already making a segment, and the new edge is a continuation of the last edge
      if segmentEdges? and isConnected(pointA, segmentEdges[segmentEdges.length-1], flowArrows)
        segmentEdges.push(pointB)
      else if segmentEdges? and isConnected(pointB, segmentEdges[segmentEdges.length-1], flowArrows)
        segmentEdges.push(pointA)      # this edge is a continuation of the last edge
      else if segmentEdges? and isConnected(segmentEdges[0], pointB, flowArrows)
        segmentEdges.unshift(pointA)
      else if segmentEdges? and isConnected(segmentEdges[0], pointA, flowArrows)
        segmentEdges.unshift(pointB)
      else
        segmentEdges = [pointA, pointB]
        segments.push(segmentEdges)
    return segments

  joinSegments = (segments, flowArrows)->
    segA = null
    segB = null
    pointA = null
    pointB = null

    i = segments.length
    while i--
      j = segments.length
      while --j > i
        segA = segments[i]
        segB = segments[j]
      
        pointA = segA[0]
        pointB = segB[0]
        if isConnected(pointA, pointB, flowArrows)
          # they're connected startA-to-startB, so flip B and merge B->A
          segB.reverse()
          segB.pop()
          segments[i] = segB.concat(segA)
          segments.splice(j, 1)
          continue
      
        # test the two segment ends
        pointA = segA[segA.length - 1]
        pointB = segB[segB.length - 1]
      
        if isConnected(pointA, pointB, flowArrows)
        # they're connected endA-to-endB, so flip B and merge A->B
          segB.reverse()
          segB.unshift()
          segments[i] = segA.concat(segB)
          segments.splice(j, 1)
          continue
      
        # test endA-to-startB
        pointA = segA[segA.length - 1]
        pointB = segB[0]
      
        if isConnected(pointA, pointB, flowArrows)
        # they're connected endA-to-startB, so merge A->B
          segments[i] = segA.concat(segB)
          segments.splice(j, 1)
          continue
      
      
        # test startA-to-endB
        pointA = segA[0]
        pointB = segB[segB.length - 1]
      
        if isConnected(pointA, pointB, flowArrows)
          # they're connected startA-to-endB, so merge B->A
          segments[i] = segB.concat(segA)
          segments.splice(j, 1)
          continue

    return segments

  cullShortEdges = (segments, flowArrows)->
    i = segments.length
    seg = []
    pointA = pointB = null
    while i--
      seg = segments[i]
      j = seg.length - 1
      while j-- > 0
        pointA = seg[j]
        pointB = seg[j+1]

        if distance(pointA, pointB) < flowArrows.MIN_EDGE_LENGTH
          pointA.cull = true

    i = segments.length
    while i--
      seg = segments[i]
      j = seg.length - 1

      while j-- > 0
        if seg[j].cull
          seg.splice(j, 1)

    return segments

  cullUnusedPoints = (segments)->
    seg = []
    pointA = null
    pointB = null
    pointC = null

    # find all points that are inline with the points on either side of it, and cull them
    i = segments.length
    while i--
      seg = segments[i]
      
      j = seg.length - 2
      
      while j-- > 0 and seg.length > 2
        pointA = seg[j]
        pointB = seg[j+1]
        pointC = seg[j+2]
        if isInline(pointA, pointB, pointC)
            seg.splice(j+1, 1)
    return segments

  cullShortSegments = (segments, flowArrows)->
    # cull short segments
    i = segments.length
    while i--
      if segments.length < flowArrows.MIN_SEGMENT_LENGTH
        segments.splice(i, 1)

    return segments

  finish = (parent, segments, arrowsContainer, flowArrows)->
    for i in [0..segments.length-1]
      segPoints = segments[i]
      segmentLength = 0
      edges = []

      # Loop through all points, and make an edge with the next point in the sequence
      for j in [0..segPoints.length - 2]
        edge = new Edge()
        edge.x = segPoints[j].x
        edge.y = segPoints[j].y
        edge.length = distance(segPoints[j], segPoints[j+1])
        edge.angle = angle(segPoints[j], segPoints[j+1]) 
        segmentLength += edge.length
        edges.push(edge)

      if segmentLength < flowArrows.MIN_SEGMENT_LENGTH
        continue
      new Segment(parent, edges, arrowsContainer, segmentLength, flowArrows)

  isConnected = (a, b, flowArrows)->
    dX = Math.abs(a.x - b.x)
    dY = Math.abs(a.y - b.y)
    return (dX < flowArrows.CONNECTED_DISTANCE and dY < flowArrows.CONNECTED_DISTANCE)

  isInline = (a, b, c)->
    crossproduct = (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y)
    if Math.abs(crossproduct) > 0.01
      return false

    dotproduct = (c.x - a.x) * (b.x - a.x) + (c.y - a.y)*(b.y - a.y)
    if dotproduct < 0
      return false

    squaredlengthba = (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y)
    if dotproduct > squaredlengthba
      return false

    return true

  distance = (a, b)->
    dx = b.x - a.x
    dy = b.y - a.y
    return Math.sqrt(dx*dx + dy*dy)

  angle = (a, b)->
    return Math.atan2(b.y - a.y, b.x - a.x)


  Make "Organizer", Organizer = 
    build: (parent, edgesData, arrowsContainer, flowArrows)->
      lineData = edgesToLines(edgesData)
      segments = []
      segments = formSegments(lineData, flowArrows) # organize the points into an array of segment groups
      segments = joinSegments(segments, flowArrows) # combine segments that are visibly connected but whose points were listed in the wrong order
      segments = cullShortEdges(segments, flowArrows) # remove points that constitute an unusably short edge
      segments = cullUnusedPoints(segments) # remove points that lie on a line, or are otherwise unnecessary

      finish(parent, segments, arrowsContainer, flowArrows) # Take all our finished point data, and make edge objects and segment objects, and add them to the container
