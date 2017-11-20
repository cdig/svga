Take ["GUI", "Mode", "SVG"], ({ControlPanel:GUI}, Mode, SVG)->
  
  constructLayout = (groups, desiredColumnHeight, vertical)->
    columns = []
    column = null
    
    # Whether we're in horizontal or vertical, our layout is built of columns.
    # Controls may be grouped together with a color, and a color group is never split across columns.
    
    for group in groups
      
      # Start a new column if we need one
      if not column? or column.height > desiredColumnHeight
        columns.push column =
          x: columns.length * (GUI.colInnerWidth + GUI.groupPad*2 + GUI.columnMargin)
          y: 0 # This will be computed once we know how tall all our columns are
          height: 0
          groups: []
      
      # Add some margin between this group and the previous
      column.height += GUI.groupMargin if column.groups.length > 0
      
      # Attach this group to the column, and assign it a position
      column.groups.push
        scope: group.scope
        y: column.height
      
      # Add this group's height to our running total
      column.height += group.height
    
    # Figure out which column is tallest, so we know how tall to make the panel
    tallestColumnHeight = 0
    for column in columns
      tallestColumnHeight = Math.max tallestColumnHeight, column.height
    
    # Set the y position for each column
    for column in columns
      column.y = if vertical
        # In vertical orientation, center-align
        tallestColumnHeight/2 - column.height/2
      else
        # In horizontal orientation, bottom-align
        tallestColumnHeight - column.height
    
    # Figure out how big to make the panel, so it fits all our columns
    innerPanelSize =
      w: GUI.panelPadding*2 + columns.length * (GUI.colInnerWidth + GUI.groupPad*2) + (columns.length-1) * GUI.columnMargin
      h: GUI.panelPadding*2 + tallestColumnHeight
    
    return [innerPanelSize, columns]
  
  
  Make "ControlPanelLayout",
    vertical: (groups, marginedSpace)->
      return [{w:0, h:0}, []] unless marginedSpace.h > 0 and groups.length > 0 # Bail if the screen is too small or we have no controls
      
      # First, get the height of the panel if it was just 1 column wide
      maxHeight = 0
      maxHeight += group.height for group in groups
      maxHeight += GUI.groupMargin * (groups.length - 1) # Add padding between all groups
      
      # Figure out how many columns we need to fit this much height.
      desiredNumberOfColumns = if Mode.embed
        1 # If we're in embed mode, we'll force it to only ever have 1 column, because that's nicer.
      else
        Math.ceil maxHeight / (marginedSpace.h - GUI.panelPadding*2)
      
      desiredColumnHeight = Math.max GUI.unit, Math.floor maxHeight / desiredNumberOfColumns
      
      return constructLayout groups, desiredColumnHeight, true
    
    
    horizontal: (groups, marginedSpace)->
      return [{w:0, h:0}, []] unless marginedSpace.w > 0 and groups.length > 0 # Bail if the screen is too small or we have no controls
      
      desiredColumnHeight = GUI.unit/2
      
      # Increase the column height until everything fits on screen
      until checkPanelSize desiredColumnHeight, groups, marginedSpace
        desiredColumnHeight += GUI.unit/4
            
      return constructLayout groups, desiredColumnHeight, false
    
    
    applyLayout: (columns, getColumnElm)->
      for column, c in columns
        columnElm = getColumnElm c
        
        SVG.attrs columnElm, transform: "translate(#{column.x},#{column.y})"
        
        for groupInfo in column.groups
          SVG.append columnElm, groupInfo.scope.element
          groupInfo.scope.y = groupInfo.y
  
  
  checkPanelSize = (columnHeight, groups, marginedSpace)->
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
    return consumedWidth < marginedSpace.w or columnHeight > marginedSpace.h/2
