Take ["ControlPanelLayout", "Gradient", "GUI", "Resize", "SVG", "Scope"], (ControlPanelLayout, Gradient, GUI, Resize, SVG, Scope)->
  CP = GUI.ControlPanel
  panelRadius = CP.borderRadius+CP.pad*2
  vertical = true
  panelWidth = 0
  panelHeight = 0
  
  Gradient.createLinear "CPGradient", false, "#5175bd", "#35488d"
  
  g = Scope SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  bg = SVG.create "rect", g.element,
    rx: panelRadius
    fill: "url(#CPGradient)"
  
  panelElms = Scope SVG.create "g", g.element
  panelElms.x = panelElms.y = CP.pad*2
  
  
  Take "ScopeReady", ()->
    Resize resize = ()->
      view = w:window.innerWidth, h:window.innerHeight
      vertical = view.w >= view.h * 1.3
      size = if vertical
        ControlPanelLayout.vertical view
      else
        ControlPanelLayout.horizontal view
      
      panelWidth = size.w + CP.pad*4
      panelHeight = size.h + CP.pad*4
      
      if vertical
        g.x = view.w - panelWidth |0
        g.y = view.h/2 - panelHeight/2 |0
        SVG.attrs bg,
          width: panelWidth + panelRadius
          height: panelHeight
      else
        g.x = view.w/2 - panelWidth/2 |0
        g.y = view.h - panelHeight |0
        SVG.attrs bg,
          width: panelWidth
          height: panelHeight + panelRadius
  
  
  Make "ControlPanel", ControlPanelView =
    createElement: (parent = null)->
      elm = SVG.create "g", parent or panelElms.element
    
    claimSpace: (rect)->
      if vertical
        rect.w -= panelWidth
      else
        rect.h -= panelHeight
