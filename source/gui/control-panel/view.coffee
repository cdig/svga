Take ["ControlPanelLayout", "GUI", "Resize", "SVG", "Scope"], (ControlPanelLayout, GUI, Resize, SVG, Scope)->
  CP = GUI.ControlPanel
  height = 0
  
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
  
  setBG = (l)-> SVG.attrs bg, fill: "hsl(220, 36%, #{l*100}%)"
  setBG 0.36
  
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
  
  # Reaction "ControlPanel:Show", ()-> Tween panelX, 1, 0.7, tick
  # Reaction "ControlPanel:Hide", ()-> Tween panelX, -.2, 0.7, tick
  # Reaction "Background:Set", (v)->
  #   setBG l = (v + .4) % 1
