Take ["GUI","Reaction","Resize","SVG","TopBar","TRS","Tween1","SVGReady"],
(      GUI , Reaction , Resize , SVG , TopBar , TRS , Tween1)->
  consumedCols = 0
  consumedRows = 0
  rows = []
  
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
  
  
  
  Reaction "GUIReady", ()->
    padX = GUI.ControlPanel.padX
    padY = GUI.ControlPanel.padY
    unit = GUI.ControlPanel.unit
    panelWidth = GUI.ControlPanel.width
    widthUnit = (panelWidth-padX*5)/4
    for row in rows
      for scope in row
        w = scope.w * widthUnit + padX * (scope.w - 1)
        h = scope.h * unit
        x = scope.x * (widthUnit + padX) + padX
        y = scope.y * unit + padY * (scope.y+1)
        scope.resize w, h
        TRS.move scope.element, x, y
  
  
  Make "ControlPanelView", ControlPanelView =
    createElement: (props)->
      TRS SVG.create "g", g, class: "#{props.name} #{props.type}", ui: true
    
    setup: (scope)->
      w = scope.w
      if consumedCols + w > 4
        consumedCols = 0
        consumedRows++
      scope.x = consumedCols
      scope.y = consumedRows
      (rows[consumedRows] ?= []).push scope
      consumedCols += w
      
