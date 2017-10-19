Take ["GUI", "Mode", "SVG"], ({ControlPanel:GUI}, Mode, SVG)->
  
  columns = []
  
  getColumn = (index, panelElm)->
    columns[index] ?=
      x: index * (GUI.colInnerWidth + GUI.groupPad*2 + GUI.columnMargin)
      groups: []
      height: 0
      visible: false
      element: SVG.create "g", panelElm
  
  performLayout = (groups, panelElm, desiredColumnHeight)->
    # Reset our columns
    for column in columns
      column.groups = []
      column.height = 0
      column.visible = false
    
    # Assemble the groups into columns
    currentColumnIndex = 0
    column = getColumn currentColumnIndex, panelElm
    for group in groups
      
      # Make a new column if we need one
      if column.height > desiredColumnHeight
        column = getColumn ++currentColumnIndex, panelElm
      
      # If we already have groups in the current column, add some space
      column.height += GUI.groupMargin if column.groups.length > 0
      
      # Attach this group to the current column, and move it into position
      column.groups.push group
      SVG.append column.element, group.scope.element
      group.scope.y = column.height
      
      # Bump the column data
      column.height += group.height
      column.visible = true
    
    # Now measure the columns
    tallestColumnHeight = 0
    for column in columns when column.visible
      # Figure out which column is tallest, so we know how tall to make the panel
      tallestColumnHeight = Math.max tallestColumnHeight, column.height
    
    # Now, position the columns
    for column in columns when column.visible
      y = tallestColumnHeight/2 - column.height/2
      SVG.attrs column.element, transform: "translate(#{column.x},#{y})"
    
    # Figure out how big to make the panel, so it fits all our columns
    panelWidth = GUI.panelPadding*2 + (currentColumnIndex+1) * (GUI.colInnerWidth + GUI.groupPad*2) + currentColumnIndex * GUI.columnMargin
    panelHeight = GUI.panelPadding*2 + tallestColumnHeight
    
    return w:panelWidth, h:panelHeight

  
  Make "ControlPanelLayout",
    vertical: (groups, availableSpace, panelElm)->
      return {w:0, h:0} unless availableSpace.h > 0 and groups.length > 0 # Bail if the screen is too small or we have no controls
      
      # First, get the total height of the panel
      totalHeight = 0
      totalHeight += group.height for group in groups
      totalHeight += GUI.groupMargin * (groups.length - 1) # Add padding between all groups
      
      # Figure out how many columns we need to fit this much height
      availableSpaceInsidePanel = availableSpace.h - GUI.panelPadding*2
      nColumns = if Mode.embed then 1 else Math.ceil totalHeight / availableSpaceInsidePanel
      desiredColumnHeight = Math.max GUI.unit, Math.floor totalHeight / nColumns
      
      return performLayout groups, panelElm, desiredColumnHeight
    
    
    horizontal: (groups, availableSpace, panelElm)->
      return {w:0, h:0} unless availableSpace.w > 0 and groups.length > 0 # Bail if the screen is too small or we have no controls
      
      desiredColumnHeight = 0
      
      # Find our tallest group
      for group in groups
        desiredColumnHeight = Math.max desiredColumnHeight, group.height
      
      # Increase the column height until everything fits on screen
      until checkPanelSize desiredColumnHeight, groups, availableSpace
        desiredColumnHeight += GUI.unit/2
      
      return performLayout groups, panelElm, desiredColumnHeight
  
  
  checkPanelSize = (columnHeight, groups, availableSpace)->
    # We'll always have at least 1 column's worth of width, plus padding on both sides
    consumedWidth = GUI.colInnerWidth + GUI.panelPadding*2
    consumedHeight = GUI.panelPadding*2
    
    nthGroupInColumn = 0
    for group in groups
      # Move to the next column if needed
      if consumedHeight > columnHeight
        consumedWidth += GUI.colInnerWidth + GUI.columnMargin
        consumedHeight = GUI.panelPadding*2
        nthGroupInColumn = 0
      consumedHeight += GUI.groupMargin if nthGroupInColumn > 0
      # Add the current group height to our current column height
      consumedHeight += group.height
      nthGroupInColumn++
    
    # We're done if we fit within the available width, or our column height gets out of hand
    return consumedWidth < availableSpace.w or columnHeight > availableSpace.h/2
