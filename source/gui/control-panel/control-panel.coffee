Take ["ControlPanelLayout", "Gradient", "GUI", "Mode", "SVG", "Scope"], (ControlPanelLayout, Gradient, GUI, Mode, SVG, Scope)->
  
  # Aliases
  CP = GUI.ControlPanel
  config = Mode.controlPanel ?= {}
  
  # State
  showing = false
  panelRadius = CP.panelBorderRadius
  vertical = true
  signedX = 0
  signedY = 0
  marginedPanelWidth = 0
  marginedPanelHeight = 0
  
  
  # Elements
  
  g = SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  bg = SVG.create "rect", g,
    rx: panelRadius
    fill: CP.bg
  
  panelElms = Scope SVG.create "g", g
  panelElms.x = panelElms.y = CP.pad*2
  
  
  Take "SceneReady", ()->
    if showing
      # All the controls have been set up by now, so let's trigger an initial resize
      resize()
    else
      # It'd be simpler to just not add the CP unless we need it,
      # rather than what we're doing here (remove it if it's unused).
      # But we need to do it this way to avoid an IE bug.
      GUI.elm.removeChild g
  
  
  ControlPanel = Scope g, ()->
    createElement: (parent = null)->
      showing = true
      elm = SVG.create "g", parent or panelElms.element
    
    claimSpace: (rect)->
      resize()
      if vertical
        rect.w -= marginedPanelWidth
      else
        rect.h -= marginedPanelHeight
    
    getAutosizePanelHeight: ()->
      if not vertical then marginedPanelHeight else 0 # Give the panel 10px of padding
    
    getAutosizePanelWidth: ()->
      if vertical then marginedPanelWidth else 0 # Give the panel 10px of padding
    
    getAutosizePanelInfo: ()->
      resize()
      signedX: signedX # These are normalized as -1 to 1
      signedY: signedY # These are normalized as -1 to 1
      w: if vertical and showing then marginedPanelWidth else 0   # These are pixel sizes
      h: if !vertical and showing then marginedPanelHeight else 0 # These are pixel sizes
  
  
  resize = ()->
    outerBounds = SVG.svg.getBoundingClientRect()
    view = w:outerBounds.width, h:outerBounds.height
    
    # TODO: Determine the vert/hori threshold based on the aspect of the content!
    vertical = if config.vertical? then config.vertical else view.w >= view.h * 1.3
    
    # Perform the layout, and get back the size of the panel contents
    panelInnerSize = if vertical
      ControlPanelLayout.vertical view
    else
      ControlPanelLayout.horizontal view
    
    # Size of the full panel
    panelWidth = panelInnerSize.w + CP.pad*4
    panelHeight = panelInnerSize.h + CP.pad*4
    
    SVG.attrs bg,
      width: panelWidth
      height: panelHeight
    
    if config.x? or config.y?
      signedX = config.x or 0
      signedY = config.y or 0
    else if vertical
      signedX = 1
      signedY = 0
    else
      signedX = 0
      signedY = 1
    
    marginedPanelWidth = panelWidth + CP.panelMargin*2
    marginedPanelHeight = panelHeight + CP.panelMargin*2
    
    marginedViewWidth = view.w - marginedPanelWidth
    marginedViewHeight = view.h - marginedPanelHeight
    
    normalizedX = (signedX/2 + 0.5)
    normalizedY = (signedY/2 + 0.5)
    
    # The control panel is a scope, so we position it using .x and .y
    ControlPanel.x = CP.panelMargin + normalizedX * marginedViewWidth |0
    ControlPanel.y = CP.panelMargin + normalizedY * marginedViewHeight |0
  
  # Init
  Make "ControlPanel", ControlPanel
