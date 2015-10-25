class Segment
  arrows: null
  direction: 1
  flow: null
  name: ""
  visible: true
  scale: 1.0
  fillColor: "white"
  constructor: (@parent, @edges, @arrowsContainer, @segmentLength, @flowArrows)->
    @arrows = []
    @name = "segment" + @arrowsContainer.segments.length
    @arrowsContainer.addSegment(@)
    self = @

    segmentArrows = Math.max(1, Math.round(self.segmentLength / @flowArrows.SPACING))
    segmentSpacing = self.segmentLength/segmentArrows;  
    position = 0
    edgeIndex = 0
    edge = self.edges[edgeIndex]

    for i in [0..segmentArrows-1]
      while (position > edge.length)
        position -= edge.length
        edge = self.edges[++edgeIndex]
      console.log "position is #{position}"
      arrow = new Arrow(self.parent, self.arrowsContainer.target, self, position, edgeIndex, @flowArrows)
      arrow.name = "arrow" + i
      self[arrow.name] = arrow
      self.arrows.push(arrow)
      position += segmentSpacing
    

  reverse: ()=>
    @direction *= -1

  setColor: (fillColor)=>
    @fillColor = fillColor


  update: (deltaTime, ancestorFlow)=>
    arrowFlow = if @flow? then @flow else ancestorFlow
    arrowFlow *= deltaTime * @direction * @flowArrows.SPEED if @flowArrows
    # if isNaN(arrowFlow)
    #   console.log "delta time #{deltaTime}"
    #   console.log "direction is #{@direction.x}"
    #   console.log "flow is #{ancestorFlow}"

    for arrow in @arrows
      arrow.setColor(@fillColor)
      arrow.update(arrowFlow)    

        


