class ArrowsContainer
  segments: null
  fadeStart: true
  fadeEnd: true
  direction: 1
  scale: 1
  name: ""
  flow: 1
  constructor: (@target)->
    @segments = []

  addSegment: (segment)=>
    @segments.push segment
    @[segment.name] = segment

  visible: (isVisible)=>
    for segment in @segments
      segment.visible(isVisible)
  reverse: ()=>
    @direction *= -1

  setColor: (fillColor)=>
    for segment in @segments
      segment.setColor(fillColor)

  update: (deltaTime)=>
    deltaTime *= @direction
    for segment in @segments
      if segment.visible
        segment.update(deltaTime, @flow)
