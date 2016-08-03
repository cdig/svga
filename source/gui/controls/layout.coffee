Take ["GUI"], (GUI)->
  gui = GUI.ControlPanel
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
      pad = gui.pad
      unit = gui.unit
      panelWidth = gui.width
      widthUnit = (panelWidth-pad*5)/4
      consumedHeight = 0
      for row in rows
        for scope in row
          w = 2 * widthUnit + pad
          h = 1 * unit
          scope.x = scope.x * (widthUnit + pad) + pad
          scope.y = scope.y * unit + pad * (scope.y + 1)
          scope.resize w, h
          consumedHeight = Math.max consumedHeight, scope.y + h
      return consumedHeight + pad
