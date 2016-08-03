Take ["GUI"], (GUI)->
  consumedCols = 0
  consumedRows = 0
  rows = []
  
  Make "ControlPanelLayout",
    addScope: (scope)->
      w = 2
      if consumedCols + w > 4
        consumedCols = 0
        consumedRows++
      scope.x = consumedCols
      scope.y = consumedRows
      (rows[consumedRows] ?= []).push scope
      consumedCols += w
    
    performLayout: ()->
      padX = GUI.ControlPanel.padX
      padY = GUI.ControlPanel.padY
      unit = GUI.ControlPanel.unit
      panelWidth = GUI.ControlPanel.width
      widthUnit = (panelWidth-padX*5)/4
      consumedHeight = 0
      for row in rows
        for scope in row
          w = 2 * widthUnit + padX
          h = 1 * unit
          scope.x = scope.x * (widthUnit + padX) + padX
          scope.y = scope.y * unit + padY * (scope.y + 1)
          scope.resize w, h
          consumedHeight = Math.max consumedHeight, scope.y + h
      return consumedHeight + padY
