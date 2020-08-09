Take ["FlowArrows:Config", "Vec"], (Config, Vec)->

  # PROCESSING STEPS ##############################################################################

  log = (a)->
    console.dir a
    a

  formSegments = (lineData)->
    segments = [] # array of segments
    segmentEdges = null # array of edges in the current segment

    # loop in pairs, since lineData is alternating start/end points of edges
    for i in [0...lineData.length] by 2
      pointA = lineData[i]
      pointB = lineData[i+1]

      # if we're already making a segment, and the new edge is a continuation of the last edge
      if segmentEdges? and isConnected(pointA, segmentEdges[segmentEdges.length-1])
        segmentEdges.push(pointB) # this edge is a continuation of the last edge
      else if segmentEdges? and isConnected(pointB, segmentEdges[segmentEdges.length-1])
        segmentEdges.push(pointA) # this edge is a continuation of the last edge

      # if we're already making a segment, and the new edge comes before the first edge
      else if segmentEdges? and isConnected(segmentEdges[0], pointB)
        segmentEdges.unshift(pointA) # the first edge is a continuation of this edge
      else if segmentEdges? and isConnected(segmentEdges[0], pointA)
        segmentEdges.unshift(pointB) # the first edge is a continuation of this edge

      # we're not yet making a segment, or the new edge isn't connected to the current segment
      else
        segments.push segmentEdges = [pointA, pointB] # this edge is for a new segment

    return segments


  joinSegments = (segments)->
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
        if isConnected(pointA, pointB)
          # they're connected startA-to-startB, so flip B and merge B->A
          segB.reverse()
          segB.pop()
          segments[i] = segB.concat(segA)
          segments.splice(j, 1)
          continue

        # test the two segment ends
        pointA = segA[segA.length - 1]
        pointB = segB[segB.length - 1]

        if isConnected(pointA, pointB)
        # they're connected endA-to-endB, so flip B and merge A->B
          segB.reverse()
          segB.unshift()
          segments[i] = segA.concat(segB)
          segments.splice(j, 1)
          continue

        # test endA-to-startB
        pointA = segA[segA.length - 1]
        pointB = segB[0]

        if isConnected(pointA, pointB)
        # they're connected endA-to-startB, so merge A->B
          segments[i] = segA.concat(segB)
          segments.splice(j, 1)
          continue


        # test startA-to-endB
        pointA = segA[0]
        pointB = segB[segB.length - 1]

        if isConnected(pointA, pointB)
          # they're connected startA-to-endB, so merge B->A
          segments[i] = segB.concat(segA)
          segments.splice(j, 1)
          continue

    return segments


  cullShortEdges = (segments)->
    i = segments.length
    seg = []
    pointA = pointB = null
    while i--
      seg = segments[i]
      j = seg.length - 1
      while j-- > 0
        pointA = seg[j]
        pointB = seg[j+1]

        if Vec.distance(pointA, pointB) < Config.MIN_EDGE_LENGTH
          pointA.cull = true

    i = segments.length
    while i--
      seg = segments[i]
      j = seg.length - 1

      while j-- > 0
        if seg[j].cull
          seg.splice(j, 1)

    return segments


  cullInlinePoints = (segments)->
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


  reifyVectors = (segments)->
    for segment in segments
      for pointA, i in segment when pointB = segment[i+1]
        vector =
          x: pointA.x
          y: pointA.y
          dist: Vec.distance pointA, pointB
          angle: Vec.angle pointA, pointB


  reifySegments = (set)->
    for segmentVectors in set
      dist = 0
      dist += vector.dist for vector in segmentVectors
      segment =
        vectors: segmentVectors
        dist: dist


  cullShortSegments = (set)->
    set.filter (segment)->
      segment.dist >= Config.MIN_SEGMENT_LENGTH


  # HELPERS #######################################################################################

  wrap = (data)->
    process: (fn)-> wrap fn data
    result: data

  isConnected = (a, b)->
    dX = Math.abs(a.x - b.x)
    dY = Math.abs(a.y - b.y)
    return (dX < Config.CONNECTED_DISTANCE and dY < Config.CONNECTED_DISTANCE)

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


  # MAIN ##########################################################################################

  Make "FlowArrows:Process", (lineData)->
    wrap lineData # Wrap our data into a format suitable for the below processing pipeline
    .process formSegments # organize the points into an array of segment groups
    .process joinSegments # combine segments that are visibly connected but whose points were listed in the wrong order
    .process cullShortEdges # remove points that constitute an unusably short edge
    .process cullInlinePoints # remove points that lie on a line
    .process reifyVectors # create vectors with a position, dist, and angle
    .process reifySegments # create segments with a dist and edges
    .process cullShortSegments # remove vectors that are unusably short
    .result # return the result after all the above processing steps
