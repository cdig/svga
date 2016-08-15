Take ["GUI"], ({ControlPanel:GUI})->
  scopes = []
  
  Make "ControlPanelLayout",
    addScope: (scope)->
      scopes.push scope
    
    
    vertical: (view)->
      return {w:0, h:0} unless view.h > 0 and scopes.length > 0 # Bail if the screen is too small or we have no controls
      
      # This approach is going to get screwed up if any element draws taller than its preferred height,
      # because the column will wrap at an inappropriate time and we'll get an extra column with an orphan or two.
      # So, the rule should be that preferredSize is the smallest size you're okay drawing at,
      # then when we call resize you MUST take the full size (no more, no less) of the bounds we give you.
      
      preferredSizes = []
      widestWidth = 0
      fullHeight = 0
      
      for scope in scopes
        preferredSizes.push s = scope.getPreferredSize()
        widestWidth = Math.max widestWidth, s.w
        fullHeight += s.h
      
      columns = Math.ceil fullHeight / view.h
      columnWidth = widestWidth # In the future, we could give each column its own width
      approxColumnHeight = Math.ceil fullHeight / columns
      
      xOffset = 0
      yOffset = 0
      tallestColumn = 0
      panelWidth = 0
      
      for scope, i in scopes
        scope.x = xOffset
        scope.y = yOffset
        scopeHeight = preferredSizes[i].h
        scope.resize w:columnWidth, h:scopeHeight
        yOffset += scopeHeight
        if yOffset > approxColumnHeight
          xOffset += widestWidth
          if yOffset > view.h and yOffset > scopeHeight
            tallestColumn = Math.max tallestColumn, yOffset - scopeHeight
            scope.x = xOffset
            scope.y = 0
            yOffset = scopeHeight
          else
            tallestColumn = Math.max tallestColumn, yOffset
            yOffset = 0
      
      tallestColumn = Math.max tallestColumn, yOffset
      
      return w:scope.x + widestWidth, h:tallestColumn
    
    
    horizontal: (view)->
      return {w:0, h:0} unless view.w > 0 and scopes.length > 0 # Bail if the screen is too small or we have no controls
      
      # This approach is going to get screwed up if any element draws wider than its preferred width,
      # because the row will wrap at an inappropriate time and we'll get an extra row with an orphan or two.
      # So, the rule should be that preferredSize is the smallest size you're okay drawing at,
      # then when we call resize you MUST take the full size (no more, no less) of the bounds we give you.
      
      preferredSizes = []
      tallestHeight = 0
      
      # Compute the size of all scopes, and the tallest of them
      for scope in scopes
        preferredSizes.push s = scope.getPreferredSize()
        tallestHeight = Math.max tallestHeight, s.h
      
      # Compute the row height, which will be at least as tall as the tallest scope
      rowHeight = tallestHeight
      rowHeight += GUI.unit until checkRowHeight rowHeight, preferredSizes, view
      
      # Compute the widths of each columns
      columnWidths = [0]
      yOffset = 0
      col = 0
      for size in preferredSizes
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
        scopeHeight = preferredSizes[i].h
        yOffset += scopeHeight
        if yOffset > rowHeight
          scope.x = xOffset += columnWidths[col]
          scope.y = 0
          yOffset = scopeHeight
          col++
        scope.resize w:columnWidths[col], h:scopeHeight
      
      return w:totalWidth, h:rowHeight
  
  
  checkRowHeight = (rowHeight, preferredSizes, view)->
    xOffset = 0
    yOffset = 0
    for size in preferredSizes
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
