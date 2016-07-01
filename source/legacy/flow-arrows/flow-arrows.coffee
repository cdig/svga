Take ["Organizer", "Reaction", "RequestUniqueAnimation"], (Organizer, Reaction, RequestUniqueAnimation)->
  currentTime = null
  
  FlowArrows =
    
    # CUSTOMIZABLE VALUES
    scale: 0.75 # Size of arrows is multiplied by this value
    SPACING: 600 # APPROXIMATELY how far apart should arrows be spaced? (+/-)50%
    FADE_LENGTH: 50 # Over how great a distance do Arrows fade in/out?
    MIN_SEGMENT_LENGTH: 1 # How long must a segment be before we put arrows on it? (Originally 200 in Flash, changed to 1 when ported to SVG)
    
    # CONSTANTS
    SPEED: 200 # The speed Arrows move when flow is 1
    MIN_EDGE_LENGTH: 8 # How long must an edge be to survive being culled?
    CONNECTED_DISTANCE: 1 # How close must two physically-disconnected points be to be treated as part of the same line?
    ARROWS_PROPERTY: "arrows" # this must be the same as the property in HydraulicPressure for flow arrows
    
    # STATE
    isVisible: false
    arrowsContainers: []
    
    
    setup: (parent, selectedSymbol, linesData)->
      removeOriginalArrow(selectedSymbol)
      arrowsContainer = new ArrowsContainer(selectedSymbol)
      FlowArrows.arrowsContainers.push arrowsContainer
      for lineData in linesData
        Organizer.build(parent,lineData.edges, arrowsContainer, this)
      
      RequestUniqueAnimation update, true
      
      return arrowsContainer
    
    show: ()->
      FlowArrows.isVisible = true
      for arrowsContainer in FlowArrows.arrowsContainers
        arrowsContainer.visible(true)
    
    hide: ()->
      FlowArrows.isVisible = false
      for arrowsContainer in FlowArrows.arrowsContainers
        arrowsContainer.visible(false)
    
    animateMode: ()->
      for arrowsContainer in FlowArrows.arrowsContainers
        arrowsContainer.visible(FlowArrows.isVisible)
    
    schematicMode: ()->
      for arrowsContainer in FlowArrows.arrowsContainers
        arrowsContainer.visible(false)
    
    start: ()->
      console.log "FlowArrows.start() is deprecated. Please remove it from your animation."
  
  
  removeOriginalArrow = (selectedSymbol)->
    children = []
    for child in selectedSymbol.childNodes
      children.push child
    for child in children
      selectedSymbol.removeChild(child)
  
  update = (time)->
    RequestUniqueAnimation(update)
    currentTime ?= time
    dT = (time - currentTime)/1000
    currentTime = time
    return unless FlowArrows.isVisible
    for arrowsContainer in FlowArrows.arrowsContainers
      arrowsContainer.update dT
  
    
  Reaction "Schematic:Show", FlowArrows.schematicMode
  Reaction "Schematic:Hide", FlowArrows.animateMode
  
  Make "FlowArrows", FlowArrows
