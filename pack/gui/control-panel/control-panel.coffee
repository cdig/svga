Take ["Config", "ControlPanelLayout", "Gradient", "GUI", "Resize", "SVG", "Scope"], (Config, ControlPanelLayout, Gradient, GUI, Resize, SVG, Scope)->
  
  # Aliases
  CP = GUI.ControlPanel
  Conf = Config.controlPanel ?= {}

  # State
  showing = false
  panelRadius = CP.borderRadius+CP.pad*2
  vertical = true
  panelWidth = 0
  panelHeight = 0

  
  # Elements

  Gradient.linear "CPGradient", false, "#5175bd", "#35488d"
  
  g = SVG.create "g", null,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  bg = SVG.create "rect", g,
    rx: panelRadius
    fill: "url(#CPGradient)"
  
  panelElms = Scope SVG.create "g", g
  panelElms.x = panelElms.y = CP.pad*2
  
  
  # Scope

  ControlPanel = Scope g, ()->
    createElement: (parent = null)->
      showing = true
      elm = SVG.create "g", parent or panelElms.element
    
    claimSpace: (rect)->
      if vertical
        rect.w -= panelWidth
      else
        rect.h -= panelHeight
  

  # Helpers
  
  resize = ()->
    view = w:window.innerWidth, h:window.innerHeight
    vertical = if Conf.vertical? then Conf.vertical else view.w >= view.h * 1.3
    size = if vertical
      ControlPanelLayout.vertical view
    else
      ControlPanelLayout.horizontal view
    panelWidth = size.w + CP.pad*4
    panelHeight = size.h + CP.pad*4
    
    widthPad = if Conf.x is 1 then panelRadius else if Conf.x is -1 then -panelRadius else if vertical then panelRadius else 0
    heightPad = if Conf.y is 1 then panelRadius else if Conf.y is -1 then -panelRadius else if !vertical then panelRadius else 0
    panelBgX = if Conf.x is -1 then -panelRadius else 0
    panelBgY = if Conf.y is -1 then -panelRadius else 0
    
    SVG.attrs bg,
      x: panelBgX
      y: panelBgY
      width: panelWidth + widthPad
      height: panelHeight + heightPad
    
    if Conf.x? or Conf.y?
      x = (Conf.x or 0)/2 + 0.5
      y = (Conf.y or 0)/2 + 0.5
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
  Take "SceneReady", ()->
    if showing
      SVG.append GUI.elm, g
      Resize resize, true
