Take ["ControlPanelLayout", "Gradient", "GUI", "Resize", "SVG", "Scope"], (ControlPanelLayout, Gradient, GUI, Resize, SVG, Scope)->
  CP = GUI.ControlPanel
  height = 0
  
  Gradient.createLinear "CPGradient", false, "#5175bd", "#35488d"
  
  g = Scope SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  bg = SVG.create "rect", g.element,
    xBg: ""
    x: -CP.pad*2
    y: -CP.pad*2
    width: CP.width + CP.pad*8
    rx: CP.borderRadius+CP.pad*2
    fill: "url(#CPGradient)"
  
  
  Resize resize = ()->
    g.x = (window.innerWidth - CP.width - CP.pad) |0
    g.y = (window.innerHeight/2 - height/2) |0
  
  
  Take "ScopeReady", ()->
    size = ControlPanelLayout.performLayout()
    height = size.h + CP.pad*4
    SVG.attrs bg, height: height
    resize()
  
  
  Make "ControlPanel", ControlPanelView =
    createElement: (parent = null)->
      elm = SVG.create "g", parent or g.element
