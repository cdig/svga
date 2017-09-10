Take ["ControlPanelLayout", "Gradient", "GUI", "Mode", "SVG", "Scope"], (ControlPanelLayout, Gradient, GUI, Mode, SVG, Scope)->
  
  # Aliases
  CP = GUI.ControlPanel
  config = Mode.controlPanel ?= {}

  # State
  showing = false
  panelRadius = CP.borderRadius+CP.pad*2
  vertical = true
  panelWidth = 0
  panelHeight = 0

  
  # Elements

  Gradient.linear "CPGradient", false, "#5175bd", "#35488d"
  
  g = SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  bg = SVG.create "rect", g,
    rx: panelRadius
    fill: "url(#CPGradient)"
  
  panelElms = Scope SVG.create "g", g
  panelElms.x = panelElms.y = CP.pad*2
  
  
  # It'd be simpler to just not add the CP unless we need it,
  # rather than what we're doing here (remove it if it's unused).
  # But we need to do it this way to avoid an IE bug.
  Take "SceneReady", ()-> GUI.elm.removeChild g if not showing

  
  # Scope

  ControlPanel = Scope g, ()->
    createElement: (parent = null)->
      showing = true
      elm = SVG.create "g", parent or panelElms.element
    
    claimSpace: (rect)->
      resize()
      if vertical
        rect.w -= panelWidth
      else if not Mode.autosize
        rect.h -= panelHeight
    
    getAutosizePanelHeight: ()->
      if Mode.autosize and not vertical then panelHeight + 10 else 0 # Give the panel 10px of padding
  
  
  # Helpers
  
  resize = ()->
    cbr = SVG.svg.getBoundingClientRect()
    view = w:cbr.width, h:cbr.height
    vertical = if config.vertical? then config.vertical else view.w >= view.h * 1.3
    size = if vertical
      ControlPanelLayout.vertical view
    else
      ControlPanelLayout.horizontal view
    panelWidth = size.w + CP.pad*4
    panelHeight = size.h + CP.pad*4
    
    widthPad = if Math.abs(config.x) is 1 then panelRadius else if config.x? then 0 else if vertical then panelRadius else 0
    heightPad = if Math.abs(config.y) is 1 then panelRadius else if config.y? then 0 else if !vertical then panelRadius else 0
    panelBgX = if config.x is -1 then -panelRadius else 0
    panelBgY = if config.y is -1 then -panelRadius else 0
    
    SVG.attrs bg,
      x: panelBgX
      y: panelBgY
      width: panelWidth + widthPad
      height: panelHeight + heightPad
    
    if config.x? or config.y?
      x = (config.x or 0)/2 + 0.5
      y = (config.y or 0)/2 + 0.5
      ControlPanel.x = x * view.w - x * panelWidth |0
      ControlPanel.y = y * view.h - y * panelHeight |0
    else if vertical
      ControlPanel.x = view.w - panelWidth |0
      ControlPanel.y = view.h/2 - panelHeight/2 |0
    else
      ControlPanel.x = view.w/2 - panelWidth/2 |0
      ControlPanel.y = view.h - panelHeight |0
  
  
  # Init
  Make "ControlPanel", ControlPanel
