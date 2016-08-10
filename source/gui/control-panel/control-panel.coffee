Take ["Config", "ControlPanelLayout", "Gradient", "GUI", "Resize", "SVG", "Scope"], (Config, ControlPanelLayout, Gradient, GUI, Resize, SVG, Scope)->
  CP = GUI.ControlPanel
  Cfg = Config.controlPanel ?= {}
  
  showing = false
  panelRadius = CP.borderRadius+CP.pad*2
  vertical = true
  panelWidth = 0
  panelHeight = 0
  
  
  Gradient.linear "CPGradient", false, "#5175bd", "#35488d"
  
  
  g = Scope SVG.create "g", null,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  bg = SVG.create "rect", g.element,
    rx: panelRadius
    fill: "url(#CPGradient)"
  
  panelElms = Scope SVG.create "g", g.element
  panelElms.x = panelElms.y = CP.pad*2
  
  
  resize = ()->
    view = w:window.innerWidth, h:window.innerHeight
    vertical = Cfg.vertical or view.w >= view.h * 1.3
    size = if vertical
      ControlPanelLayout.vertical view
    else
      ControlPanelLayout.horizontal view
    panelWidth = size.w + CP.pad*4
    panelHeight = size.h + CP.pad*4
    widthPad = if Cfg.x is 1 then panelRadius else if Cfg.x is -1 then -panelRadius else 0
    heightPad = if Cfg.y is 1 then panelRadius else if Cfg.y is -1 then -panelRadius else 0
    panelBgX = if Cfg.x is -1 then -panelRadius else 0
    panelBgY = if Cfg.y is -1 then -panelRadius else 0
    
    SVG.attrs bg,
      x: panelBgX
      y: panelBgY
      width: panelWidth + widthPad
      height: panelHeight + heightPad
    
    if Cfg.x? or Cfg.y?
      x = (Cfg.x or 0)/2 + 0.5
      y = (Cfg.y or 0)/2 + 0.5
      g.x = x * view.w - x * panelWidth |0
      g.y = y * view.h - y * panelHeight |0
    else if vertical
      g.x = view.w - panelWidth |0
      g.y = view.h/2 - panelHeight/2 |0
    else
      g.x = view.w/2 - panelWidth/2 |0
      g.y = view.h - panelHeight |0
  
  Take "ScopeReady", ()->
    Resize resize, true
  
  Make "ControlPanel", ControlPanelView =
    show: ()->
      if not showing
        showing = true
        SVG.append GUI.elm, g.element
    
    createElement: (parent = null)->
      elm = SVG.create "g", parent or panelElms.element
    
    claimSpace: (rect)->
      if vertical
        rect.w -= panelWidth
      else
        rect.h -= panelHeight
