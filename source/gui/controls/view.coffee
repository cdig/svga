Take ["ControlPanelLayout", "GUI", "Resize", "SVG", "TRS"], (ControlPanelLayout, GUI, Resize, SVG, TRS)->
  
  g = TRS SVG.create "g", GUI.elm,
    "x-controls": ""
    "font-size": 20
    "text-anchor": "middle"
  
  bg = SVG.create "rect", g,
    "x-bg": ""
    width: GUI.ControlPanel.width
    rx: GUI.ControlPanel.borderRadius
    ry: GUI.ControlPanel.borderRadius
  
  
  Resize ()->
    x = (window.innerWidth/2 - GUI.ControlPanel.width/2) |0
    y = (window.innerHeight/2 - GUI.ControlPanel.width/2) |0
    TRS.move g, x, y
  
  
  # Reaction "ControlPanel:Show", ()-> Tween panelX, 1, 0.7, tick
  # Reaction "ControlPanel:Hide", ()-> Tween panelX, -.2, 0.7, tick
  # Reaction "Background:Set", (v)->
  #   l = (v + .4) % 1
  #   SVG.attr bg, "fill", "hsl(230, 10%, #{l*100}%)"

  
  Take "ScopeReady", ()->
    h = ControlPanelLayout.performLayout()
    SVG.attr bg, "height", h
  
  
  Make "ControlPanel", ControlPanelView =
    createElement: (parent = null)->
      elm = SVG.create "g", parent or g, ui: true
