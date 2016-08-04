Take ["GUI", "LayoutRow"], ({ControlPanel:GUI}, LayoutRow)->
  rows = [LayoutRow()]
  
  Make "ControlPanelLayout",
    addScope: (scope)->
      size = scope.getPreferredSize()
      currentRow = rows[rows.length-1]
      if currentRow.hasSpace size
        currentRow.add scope, size
      else
        rows.push currentRow = LayoutRow()
        currentRow.add scope, size
    
    performLayout: (view)->
      aspect = view.w / view.h
      vertical = aspect > 1
      if vertical
        verticalLayout view, vertical
      else
        horizontalLayout view, vertical
  
  
  verticalLayout = (view, vertical)->
    size = w:0, h:0
    for row in rows
      s = row.resize x:0, y:size.h, view, vertical
      size.w = s.w
      size.h += s.h
    return size

  
  horizontalLayout = (view, vertical)->
    return {w:0, h:0} unless view.w > 1
    rowsPerCol = 0
    result = null
    while !result?
      rowsPerCol++
      result = attemptHorizontalLayout view, vertical, rowsPerCol
    return result
  
  
  attemptHorizontalLayout = (view, vertical, rowsPerCol)->
    xOffset = 0
    yOffset = 0
    h = 0
    consumedRows = 0
    
    for row, i in rows

      if consumedRows >= rowsPerCol
        consumedRows = 0
        xOffset += GUI.width
        return null if xOffset + GUI.width >= view.w
        h = Math.max h, yOffset
        yOffset = 0
        
      s = row.resize x:xOffset, y:yOffset, view, vertical
      yOffset += s.h
      consumedRows++ if s.h > 0

    return w:xOffset + GUI.width, h:Math.max h, yOffset
