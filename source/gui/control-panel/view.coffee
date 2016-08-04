Take ["ControlPanelLayout", "Gradient", "GUI", "Resize", "SVG", "Scope"], (ControlPanelLayout, Gradient, GUI, Resize, SVG, Scope)->
  CP = GUI.ControlPanel
  
  Gradient.createLinear "CPGradient", false, "#5175bd", "#35488d"
  
  g = Scope SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  bg = SVG.create "rect", g.element,
    rx: CP.borderRadius+CP.pad*2
    fill: "url(#CPGradient)"
  
  panelElms = Scope SVG.create "g", g.element
  panelElms.x = panelElms.y = CP.pad*2
  
  Take "ScopeReady", ()->
    Resize resize = ()->
      view = w:window.innerWidth, h:window.innerHeight
      size = ControlPanelLayout.performLayout view
      panelWidth = size.w + CP.pad*4
      panelHeight = size.h + CP.pad*4
      SVG.attrs bg,
        width: panelWidth
        height: panelHeight
      g.x = view.w/2 - panelWidth/2 |0
      g.y = view.h/2 - panelHeight/2 |0
  
  
  Make "ControlPanel", ControlPanelView =
    createElement: (parent = null)->
      elm = SVG.create "g", parent or panelElms.element
