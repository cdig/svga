Take ["ControlPanelLayout", "GUI", "Resize", "SVG", "Scope"], (ControlPanelLayout, GUI, Resize, SVG, Scope)->
  CP = GUI.ControlPanel
  height = 0
  
  g = Scope SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 20
    textAnchor: "middle"
  
  bg = SVG.create "rect", g.element,
    xBg: ""
    x: -CP.pad
    y: -CP.pad
    width: CP.width + CP.pad*2
    rx: CP.borderRadius+CP.pad*2
  
  
  Resize resize = ()->
    g.x = (window.innerWidth/2 - CP.width/2) |0
    g.y = (window.innerHeight/2 - height/2) |0
  
  
  Take "ScopeReady", ()->
    size = ControlPanelLayout.performLayout()
    height = size.h + CP.pad*2
    SVG.attrs bg, height: height
    resize()
  
  
  Make "ControlPanel", ControlPanelView =
    createElement: (parent = null)->
      elm = SVG.create "g", parent or g.element
  
  
  # Reaction "ControlPanel:Show", ()-> Tween panelX, 1, 0.7, tick
  # Reaction "ControlPanel:Hide", ()-> Tween panelX, -.2, 0.7, tick
  # Reaction "Background:Set", (v)->
  #   l = (v + .4) % 1
  #   SVG.attrs bg, fill: "hsl(230, 10%, #{l*100}%)"
