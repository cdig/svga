Take ["SVG", "SVGReady"], (SVG)->
  Make "GUI", GUI =
    elm: SVG.create "g", SVG.svg, xGui:""
    ControlPanel:
      borderRadius: 4
      groupBorderRadius: groupBorderRadius = 4
      panelMargin: 4 # Space between the panel and the edge of the window
      itemPad: itemPad = 16 # Vertical space between items in a column
      groupPad: groupPad = itemPad*2/5 + groupBorderRadius*2/3 # Size of the "group box" around the sides of an item
      unit: unit = 32
      colUnits: colUnits = 5
      columnPadding: columnPadding = groupPad*2 + 8 # Space between columns
      panelPadding: groupPad + 8 # Space between the items and the panel edge
      colInnerWidth: colInnerWidth = unit * colUnits # Width of items in a column
      
      width: 200 # DEPRECATED
      pad: 0 # DEPRECATED
      colOuterWidth: colInnerWidth # DEPRECATED
