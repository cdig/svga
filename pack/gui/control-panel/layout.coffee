Take ["GUI"], ({ControlPanel:GUI})->
  scopes = []
  
  Make "ControlPanelLayout",
    addScope: (scope)->
      scopes.push scope
    
    
    vertical: (view)->
      return {w:0, h:0} unless view.h > 0 and scopes.length > 0 # Bail if the screen is too small or we have no controls
      
      # First pass: preferred sizes
      sizes = []
      columnWidth = 0
      
      for scope in scopes
        size = scope.getPreferredSize null, view, true
        sizes.push size
        columnWidth = Math.max columnWidth, size.w
      
      # Second pass: actual sizes
      fullHeight = 0
      
      for scope, i in scopes
        oldSize = sizes[i]
        newSize = scope.resize w:columnWidth, h:oldSize.h, view, true
        sizes[i] = newSize
        fullHeight += newSize.h
      
      # Third pass: layout
      columns = Math.ceil fullHeight / view.h
      approxColumnHeight = Math.ceil fullHeight / columns
      
      xOffset = 0
      yOffset = 0
      tallestColumn = 0
      panelWidth = 0
      
      for scope, i in scopes
        scope.x = xOffset
        scope.y = yOffset
        size = sizes[i]
        yOffset += size.h
        if yOffset > approxColumnHeight
          xOffset += columnWidth
          if yOffset > view.h and yOffset > size.h
            tallestColumn = Math.max tallestColumn, yOffset - size.h
            scope.x = xOffset
            scope.y = 0
            yOffset = size.h
          else
            tallestColumn = Math.max tallestColumn, yOffset
            yOffset = 0
      
      tallestColumn = Math.max tallestColumn, yOffset
      
      return w:scope.x + columnWidth, h:tallestColumn
    
    
    horizontal: (view)->
      return {w:0, h:0} unless view.w > 0 and scopes.length > 0 # Bail if the screen is too small or we have no controls
      
      # First pass: preferred sizes
      sizes = []
      rowHeight = 0
      
      for scope in scopes
        size = scope.getPreferredSize null, view, false
        sizes.push size
        rowHeight = Math.max rowHeight, size.h
      
      rowHeight += GUI.unit until checkRowHeight rowHeight, sizes, view
      
      # Second pass: actual sizes
      for scope, i in scopes
        oldSize = sizes[i]
        newSize = scope.resize w:oldSize.w, h:rowHeight, view, false
        sizes[i] = newSize
        rowHeight = Math.max rowHeight, size.h
      
      rowHeight += GUI.unit until checkRowHeight rowHeight, sizes, view
      
      
      # Compute the widths of each columns
      columnWidths = [0]
      yOffset = 0
      col = 0
      for size in sizes
        yOffset += size.h
        if yOffset > rowHeight
          col++
          columnWidths[col] = 0
          yOffset = size.h
        columnWidths[col] = Math.max size.w, columnWidths[col]
      
      # Compute the total width of the panel
      totalWidth = 0
      totalWidth += columnWidth for columnWidth in columnWidths
      
      # Perform the layout
      xOffset = 0
      yOffset = 0
      col = 0
      for scope, i in scopes
        scope.x = xOffset
        scope.y = yOffset
        scopeHeight = sizes[i].h
        yOffset += scopeHeight
        if yOffset > rowHeight
          scope.x = xOffset += columnWidths[col]
          scope.y = 0
          yOffset = scopeHeight
          col++
        scope.resize w:columnWidths[col], h:scopeHeight, view, false # See the notes above for scope.getPreferredSize in vertical
      
      return w:totalWidth, h:rowHeight
  
  
  checkRowHeight = (rowHeight, sizes, view)->
    xOffset = 0
    yOffset = 0
    for size in sizes
      yOffset += size.h
      if yOffset > rowHeight
        xOffset += size.w
        yOffset = size.h
    if xOffset + size.w < view.w # We've found a good row height!
      true
    else if rowHeight > view.h / 2 # We're too tall; bail.
      true
    else # No good, try again.
      false
