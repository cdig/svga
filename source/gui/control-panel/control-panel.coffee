Take ["ControlPanelLayout", "Gradient", "GUI", "Mode", "SVG", "Scope", "TRS"], (ControlPanelLayout, Gradient, GUI, Mode, SVG, Scope, TRS)->
  
  # Aliases
  CP = GUI.ControlPanel
  config = Mode.controlPanel ?= {}
  
  # State
  showing = false
  groups = []
  
  # Elements
  
  panelElm = SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  panelBg = SVG.create "rect", panelElm,
    xPanelBg: ""
    rx: CP.panelBorderRadius
    fill: "hsl(220, 45%, 45%)"
  
  columnsElm = SVG.create "g", panelElm,
    xColumns: ""
    transform: "translate(#{CP.panelPadding},#{CP.panelPadding})"
  
  
  Take "SceneReady", ()->
    if !showing
      # It'd be simpler to just not add the CP unless we need it,
      # rather than what we're doing here (remove it if it's unused).
      # But we need to do it this way to avoid an IE bug.
      GUI.elm.removeChild panelElm
  
  
  makePanelInfo = (vertical, panelSize, view)->
    
    # If the panel is still way the hell too big, scale down
    controlPanelScale = if vertical and (panelSize.w > view.w/2 or panelSize.h > view.h)
      Math.max 0.7, Math.min view.w / panelSize.w / 2, view.h / panelSize.h
    else if !vertical and (panelSize.h > view.h/2 or panelSize.w > view.w)
      Math.max 0.7, Math.min view.w / panelSize.w, view.h / panelSize.h / 2
    else
      1
    
    # controlPanelScale = 1
    
    scaledPanelW = panelSize.w * controlPanelScale
    scaledPanelH = panelSize.h * controlPanelScale
    
    # Take("HUD")
    #   test: (vertical and scaledPanelW > view.w/2) or (!vertical and scaledPanelH > view.h/2)
    
    if config.x? or config.y?
      signedXPosition = config.x or 0
      signedYPosition = config.y or 0
    else if vertical
      signedXPosition = 1
      signedYPosition = 0
    else
      signedXPosition = 0
      signedYPosition = 1
    
    marginedViewWidth = view.w - scaledPanelW
    marginedViewHeight = view.h - scaledPanelH
    
    normalizedX = (signedXPosition/2 + 0.5)
    normalizedY = (signedYPosition/2 + 0.5)
    
    controlPanelX = CP.panelMargin + normalizedX * marginedViewWidth |0
    controlPanelY = CP.panelMargin + normalizedY * marginedViewHeight |0
    
    return panelInfo =
      controlPanelScale: controlPanelScale
      controlPanelX: controlPanelX
      controlPanelY: controlPanelY
      vertical: vertical
      signedX: signedXPosition # These are normalized as -1 to 1
      signedY: signedYPosition # These are normalized as -1 to 1
      w: scaledPanelW + CP.panelMargin*2 # These are pixel sizes
      h: scaledPanelH + CP.panelMargin*2 # These are pixel sizes
  
  
  Make "ControlPanel", ControlPanel = Scope panelElm, ()->
    registerGroup: (group)->
      groups.push group
    
    createItemElement: (parent)->
      showing = true
      SVG.create "g", parent
    
    getPanelLayoutInfo: (horizontalIsBetter)->
      outerBounds = SVG.svg.getBoundingClientRect()
      
      view =
        w: outerBounds.width - CP.panelMargin*2
        h: outerBounds.height - CP.panelMargin*2
      
      # Perform the layout, and store the size and orientation of the panel
      if config.vertical is true
        vertical = true
        panelSize = ControlPanelLayout.vertical groups, view, columnsElm
      else if config.vertical is false
        vertical = false
        panelSize = ControlPanelLayout.horizontal groups, view, columnsElm
      else # Try both orientations, and go with whichever one maximizes the scale of the content
        horizontalPanelSize = ControlPanelLayout.horizontal groups, view, columnsElm
        verticalPanelSize = ControlPanelLayout.vertical groups, view, columnsElm
        
        horizontalPanelInfo = makePanelInfo false, horizontalPanelSize, view
        verticalPanelInfo = makePanelInfo true, verticalPanelSize, view
        
        # We're currently in vertical orientation (since it was done last). Switch back to horizontal if need be.
        if horizontalIsBetter horizontalPanelInfo, verticalPanelInfo
          vertical = false
          panelSize = ControlPanelLayout.horizontal groups, view, columnsElm
        else
          vertical = true
          panelSize = verticalPanelSize
      
      panelInfo = makePanelInfo vertical, panelSize, view
      
      SVG.attrs panelBg,
        width: panelSize.w
        height: panelSize.h
      
      ControlPanel.scale = panelInfo.controlPanelScale
      ControlPanel.x = panelInfo.controlPanelX
      ControlPanel.y = panelInfo.controlPanelY
      
      return panelInfo
