Take ["ControlPanelLayout", "Gradient", "GUI", "Mode", "SVG", "Scope", "TRS"], (ControlPanelLayout, Gradient, GUI, Mode, SVG, Scope, TRS)->
  
  # Aliases
  CP = GUI.ControlPanel
  config = Mode.controlPanel ?= {}
  
  # State
  showing = false
  vertical = true
  signedXPosition = 0
  signedYPosition = 0
  panelSize = {w:0, h: 0}
  itemScopes = []
  
  # Elements
  
  panelElm = SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  panelBg = SVG.create "rect", panelElm,
    xPanelBg: ""
    rx: 8
    fill: "hsl(220, 45%, 45%)"
  
  columnsElm = SVG.create "g", panelElm,
    xColumns: ""
    transform: "translate(#{CP.panelPadding},#{CP.panelPadding})"
  
  
  Take "SceneReady", ()->
    if showing
      # All the controls have been set up by now, so let's trigger an initial resize
      resize()
    else
      # It'd be simpler to just not add the CP unless we need it,
      # rather than what we're doing here (remove it if it's unused).
      # But we need to do it this way to avoid an IE bug.
      GUI.elm.removeChild panelElm
  
  
  ControlPanel = Scope panelElm, ()->
    createItemElement: (parent = null, group = null)->
      showing = true
      elm = SVG.create "g", parent or columnsElm # We use columnsElm as a temporary holding place for panel items (in addition to the real parent for columns). Items will later be moved into actual columns, but for now they need to be given a real parent so they get fully styled and can be measured.
    
    registerItemScope: (scope)->
      itemScopes.push scope
    
    getPanelLayoutInfo: ()->
      resize()
      vertical: vertical
      signedX: signedXPosition # These are normalized as -1 to 1
      signedY: signedYPosition # These are normalized as -1 to 1
      w: panelSize.w + CP.panelMargin*2 # These are pixel sizes
      h: panelSize.h + CP.panelMargin*2 # These are pixel sizes
  
  
  resize = ()->
    outerBounds = SVG.svg.getBoundingClientRect()
    view =
      w: outerBounds.width - CP.panelMargin*2
      h: outerBounds.height - CP.panelMargin*2
    
    vertical = if config.vertical?
      if isNaN parseInt config.vertical # vertical set to true/false
        config.vertical
      else # verical set to an int
        view.w >= config.vertical
    else # vertical not set (default)
      if Mode.embed
        view.w >= 800
      else
        # TODO: Determine the vert/hori threshold based on the aspect of the content!
        view.w >= view.h * 1.3
    
    # Perform the layout, and get back the size of the panel
    panelSize = if vertical
      ControlPanelLayout.vertical itemScopes, view, columnsElm
    else
      ControlPanelLayout.horizontal itemScopes, view, columnsElm

    SVG.attrs panelBg,
      width: panelSize.w
      height: panelSize.h
    
    # If the panel is still way the hell too big, scale down
    if vertical and (panelSize.w > view.w/2 or panelSize.h > view.h)
      ControlPanel.scale = Math.min view.w / panelSize.w / 2, view.h / panelSize.h
    else if !vertical and (panelSize.h > view.h/2 or panelSize.w > view.w)
      ControlPanel.scale = Math.min view.w / panelSize.w, view.h / panelSize.h / 2
    else
      ControlPanel.scale = 1
    
    panelSize.w *= ControlPanel.scale
    panelSize.h *= ControlPanel.scale
    
    # Take("HUD")
    #   test: (vertical and panelSize.w > view.w/2) or (!vertical and panelSize.h > view.h/2)
    
    if config.x? or config.y?
      signedXPosition = config.x or 0
      signedYPosition = config.y or 0
    else if vertical
      signedXPosition = 1
      signedYPosition = 0
    else
      signedXPosition = 0
      signedYPosition = 1
    
    marginedViewWidth = view.w - panelSize.w
    marginedViewHeight = view.h - panelSize.h
    
    normalizedX = (signedXPosition/2 + 0.5)
    normalizedY = (signedYPosition/2 + 0.5)
    
    # The control panel is a scope, so we position it using .x and .y
    ControlPanel.x = CP.panelMargin + normalizedX * marginedViewWidth |0
    ControlPanel.y = CP.panelMargin + normalizedY * marginedViewHeight |0
  
  # Init
  Make "ControlPanel", ControlPanel
