Take ["GUI","Reaction","Resize","SVG","TopBar","TRS","Tween1","SVGReady"],
(      GUI , Reaction , Resize , SVG , TopBar , TRS , Tween1)->
  
  panelX = 0
  
  g = TRS SVG.create "g", SVG.root,
    class: "Controls"
    "font-size": 20
    "text-anchor": "middle"
  
  bg = SVG.create "rect", g,
    class: "BG"
    width: GUI.ControlPanel.width
    fill: "hsl(230, 6%, 17%)"
  
  
  positionPanel = ()->
    x = window.innerWidth - GUI.ControlPanel.width * panelX
    y = TopBar.height
    TRS.move g, x, y
  
  tick = (v)->
    panelX = v
    positionPanel()
  
  
  Resize ()->
    SVG.attr bg, "height", window.innerHeight
    positionPanel()
  
  
  Reaction "ControlPanel:Show", ()-> Tween1 panelX, 1, 0.7, tick
  Reaction "ControlPanel:Hide", ()-> Tween1 panelX, 0, 0.7, tick
  
  
  Make "ControlPanelView", ControlPanelView =
    createElement: (name, type)->
      TRS SVG.create "g", g, class: "#{name} #{type}", ui: true
    
    position: (element, x, y)->
      u = GUI.ControlPanel.unit
      TRS.move element, x * u, y * u
