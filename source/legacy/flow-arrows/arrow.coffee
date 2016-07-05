class Arrow
  edge: null
  element: null
  visible: false
  deltaFlow: 0
  vector: null
  constructor: (@parent, @target, @segment, @position, @edgeIndex, @flowArrows)->
    @createArrow()
    @edge = @segment.edges[@edgeIndex]
    self = @


  createArrow: ()=>
    @element = document.createElementNS("http://www.w3.org/2000/svg", "g")
    triangle = document.createElementNS("http://www.w3.org/2000/svg", "polygon")
    triangle.setAttributeNS(null, "points", "0,-16 30,0 0,16");
    line = document.createElementNS("http://www.w3.org/2000/svg", "polygon")
    line.setAttributeNS(null, "points", "0, 0, -23, 0")
    line.setAttributeNS(null,"fill", "#fff")
    line.setAttributeNS(null, "stroke-width", "11")

    @element.appendChild(triangle)
    @element.appendChild(line)
    @target.appendChild(@element)
    @element.setAttributeNS(null, "fill", "blue")
    @element.setAttributeNS(null, "stroke", "blue")

  setColor: (fillColor)=>
    @element.setAttributeNS(null, "fill", fillColor)
    @element.setAttributeNS(null, "stroke", fillColor)
  
  updateVisibility: ()=>
    if @visible and @deltaFlow isnt 0
      @element.style.visibility = "visible" if @element.style.visibility isnt "visible"
    else
      @element.style.visibility = "hidden" if @element.style.visibility isnt "hidden"
  
  setVisibility: (isVisible)=>
    @visible = isVisible
    @updateVisibility()
  
  update: (deltaFlow)=>
    @deltaFlow = deltaFlow
    @updateVisibility()
    
    @position += deltaFlow
    while @position > @edge.length
      @edgeIndex++
      if @edgeIndex >= @segment.edges.length
        @edgeIndex = 0

      @position -= @edge.length

      @edge = @segment.edges[@edgeIndex]

    while @position < 0
      @edgeIndex--
      if @edgeIndex < 0
        @edgeIndex = @segment.edges.length - 1
      @edge = @segment.edges[@edgeIndex]
      @position += @edge.length

    scaleFactor = 0
    fadeLength = if @flowArrows then @flowArrows.FADE_LENGTH else 50
    scaleFactor = getScaleFactor(@position, @segment.edges, @edgeIndex, fadeLength)
    scalingFactor = @segment.scale * @segment.arrowsContainer.scale
    scalingFactor *= @flowArrows.scale if @flowArrows
    scaleFactor = scaleFactor * scalingFactor

    currentPosition = {x: 0, y: 0}
    currentPosition.x = Math.cos(@edge.angle) * @position + @edge.x
    currentPosition.y = Math.sin(@edge.angle) * @position + @edge.y
    angle = @edge.angle * 180 / Math.PI + if deltaFlow < 0 then 180 else 0
    transString = "translate(#{currentPosition.x}, #{currentPosition.y}) scale(#{scaleFactor}) rotate(#{angle})"
    @element.setAttribute('transform', transString)

  getScaleFactor = (position, edges, edgeIndex, fadeLength)->
    edge = edges[edgeIndex]
    firstHalf = position < edge.length/2
    fadeStart = (firstHalf or edges.length > 1) and edgeIndex is 0
    fadeEnd = (not firstHalf or edges.length > 1) and edgeIndex is edges.length - 1
    scale = 1
    if fadeStart
      scale = (position / edge.length) * edge.length / fadeLength
    else if fadeEnd
      scale = 1.0 - (position - (edge.length - fadeLength))/fadeLength
    return Math.min(1, scale)