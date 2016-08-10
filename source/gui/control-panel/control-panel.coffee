Take ["Config", "ControlPanelLayout", "Gradient", "GUI", "Resize", "SVG", "Scope"], (Config, ControlPanelLayout, Gradient, GUI, Resize, SVG, Scope)->
  CP = GUI.ControlPanel
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
    vertical = Config.controlPanel?.vertical or view.w >= view.h * 1.3
    size = if vertical
      ControlPanelLayout.vertical view
    else
      ControlPanelLayout.horizontal view
    
    panelWidth = size.w + CP.pad*4
    panelHeight = size.h + CP.pad*4
    
    x = Config.controlPanel?.x
    y = Config.controlPanel?.y
    
    if vertical
      g.x = if x? then x else view.w - panelWidth |0
      g.y = if y? then y else view.h/2 - panelHeight/2 |0
      SVG.attrs bg,
        width: panelWidth + panelRadius
        height: panelHeight
    else
      g.x = if x? then x else view.w/2 - panelWidth/2 |0
      g.y = if y? then y else view.h - panelHeight |0
      SVG.attrs bg,
        width: panelWidth
        height: panelHeight + panelRadius
  
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
