Take ["GUI", "Mode", "SVG"], ({ControlPanel:GUI}, Mode, SVG)->
  
  columns = []
  
  getColumn = (index, panelElm)->
    columns[index] ?=
      x: index * (GUI.colInnerWidth + GUI.columnPadding)
      itemScopes: []
      height: 0
      element: SVG.create "g", panelElm
  
  performLayout = (itemScopes, panelElm, desiredColumnHeight)->
    # Reset our columns
    for column in columns
      column.itemScopes = []
      column.height = 0
    
    # Assemble the items into columns
    colIndex = 0
    column = getColumn colIndex, panelElm
    for scope, i in itemScopes
      
      # Make a new column if we need one
      if column.height > desiredColumnHeight and column.itemScopes.length > 0
        column = getColumn ++colIndex, panelElm
      
      # Attach this item to the current column, and move it to the right position
      column.itemScopes.push scope
      SVG.append column.element, scope.element
      scope.y = column.height
      
      # Keep track of how tall the column is
      column.height += scope.height + GUI.itemPad
    
    # Now measure the columns
    tallestColumnHeight = 0
    nVisibleColumns = 0
    for column, c in columns when column.itemScopes.length > 0
      # Let's keep track of how many columns we're currently using
      nVisibleColumns++

      # The bottom item in the column doesn't need padding, so remove 1 item's worth of padding
      column.height -= GUI.itemPad
      
      # Figure out which column is tallest, so we know how tall to make the panel
      tallestColumnHeight = Math.max tallestColumnHeight, column.height
    
    # Now, position the columns
    for column in columns when column.itemScopes.length > 0
      y = tallestColumnHeight/2 - column.height/2
      SVG.attrs column.element, transform: "translate(#{column.x},#{y})"
    
    # Figure out how big to make the panel, so it fits all our columns
    panelWidth = GUI.panelPadding*2 + nVisibleColumns * GUI.colInnerWidth + (nVisibleColumns-1) * GUI.columnPadding
    panelHeight = tallestColumnHeight + GUI.panelPadding*2
    
    return w:panelWidth, h:panelHeight

  
  Make "ControlPanelLayout",
    vertical: (itemScopes, availableSpace, panelElm)->
      return {w:0, h:0} unless availableSpace.h > 0 and itemScopes.length > 0 # Bail if the screen is too small or we have no controls
      
      # First, get the total height of all items in the panel
      totalHeight = GUI.panelPadding*2 # Include the padding above/below columns
      totalHeight += scope.height for scope in itemScopes
      totalHeight += GUI.itemPad * (itemScopes.length - 1) # Add bottom padding for all but 1 items
      
      # Figure out how many columns we need to fit this much height
      nColumns = if Mode.embed then 1 else Math.ceil totalHeight / availableSpace.h
      desiredColumnHeight = Math.ceil totalHeight / nColumns
      
      return performLayout itemScopes, panelElm, desiredColumnHeight
    
    
    horizontal: (itemScopes, availableSpace, panelElm)->
      return {w:0, h:0} unless availableSpace.w > 0 and itemScopes.length > 0 # Bail if the screen is too small or we have no controls
      
      desiredColumnHeight = 0
      
      # Find our tallest item
      for scope in itemScopes
        desiredColumnHeight = Math.max desiredColumnHeight, scope.height
      
      # Increase the column height until everything fits on screen
      until checkPanelSize desiredColumnHeight, itemScopes, availableSpace
        desiredColumnHeight += GUI.unit/2
      
      return performLayout itemScopes, panelElm, desiredColumnHeight
  
  
  checkPanelSize = (columnHeight, itemScopes, availableSpace)->
    # We'll always have at least 1 column's worth of width, plus padding on both sides
    consumedWidth = GUI.colInnerWidth + GUI.panelPadding*2
    consumedHeight = GUI.panelPadding*2
    
    for scope in itemScopes
      # Move to the next column if needed
      if consumedHeight > columnHeight
        consumedWidth += GUI.colInnerWidth + GUI.columnPadding
        consumedHeight = GUI.panelPadding*2
      # Add the current scope height to our current column height
      consumedHeight += scope.height + GUI.itemPad
    
    # We're done if we fit within the available width, or our column height gets out of hand
    return consumedWidth < availableSpace.w or columnHeight > availableSpace.h/2
