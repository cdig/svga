Take ["GUI","Reaction","Resize","SVG","TopBar","TRS","Tween","SVGReady"],
(      GUI , Reaction , Resize , SVG , TopBar , TRS , Tween)->
  consumedCols = 0
  consumedRows = 0
  rows = []
  
  panelX = 1
  
  g = TRS SVG.create "g", GUI.elm,
    class: "Controls"
    "font-size": 20
    "text-anchor": "middle"
  
  bg = SVG.create "rect", g,
    class: "BG"
    width: GUI.ControlPanel.width
    rx: GUI.ControlPanel.borderRadius
    ry: GUI.ControlPanel.borderRadius
  
  
  positionPanel = ()->
    x = (window.innerWidth/2 - GUI.ControlPanel.width/2) |0
    y = (window.innerHeight/2 - GUI.ControlPanel.width/2) |0
    TRS.move g, x, y
  
  tick = (v)->
    panelX = v
    positionPanel()
  
  
  Resize ()->
    positionPanel()
  
  
  Reaction "ControlPanel:Show", ()-> Tween panelX, 1, 0.7, tick
  Reaction "ControlPanel:Hide", ()-> Tween panelX, -.2, 0.7, tick
  
  
  Reaction "Background:Set", (v)->
    l = (v + .4) % 1
    SVG.attr bg, "fill", "hsl(230, 10%, #{l*100}%)"
  
  
  Take "ScopeReady", ()->
    padX = GUI.ControlPanel.padX
    padY = GUI.ControlPanel.padY
    unit = GUI.ControlPanel.unit
    panelWidth = GUI.ControlPanel.width
    widthUnit = (panelWidth-padX*5)/4
    consumedHeight = 0
    for row in rows
      for scope in row
        w = 1 * widthUnit + padX * (scope.w - 1)
        h = 1 * unit
        scope.x = scope.x * (widthUnit + padX) + padX
        scope.y = scope.y * unit + padY * (scope.y+1)
        scope.resize w, h
        consumedHeight = Math.max consumedHeight, scope.y + h
    SVG.attr bg, "height", consumedHeight + padY

  
  Make "ControlPanelView", ControlPanelView =
    createElement: (parent = null)->
      elm = SVG.create "g", parent or g, ui: true
    
    layout: (scope)->
      w = 1
      if consumedCols + w > 4
        consumedCols = 0
        consumedRows++
      scope.x = consumedCols
      scope.y = consumedRows
      (rows[consumedRows] ?= []).push scope
      consumedCols += w
      
