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
      
    
    performLayout: ()->
      size = w:0, h:0
      for row in rows
        s = row.resize x:0, y:size.h
        size.w += s.w
        size.h += s.h
      return size
