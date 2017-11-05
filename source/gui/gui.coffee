Take ["SVG", "SVGReady"], (SVG)->
  Make "GUI", GUI =
    elm: SVG.create "g", SVG.svg, xGui:""
    ControlPanel:
      borderRadius: 4
      groupBorderRadius: groupBorderRadius = 6
      panelBorderRadius: 8
      panelMargin: 4 # Space between the panel and the edge of the window
      panelPadding: 6 # Padding inside the panel
      columnMargin: 5 # Horizontal space between two columns
      groupMargin: 4 # Vertical space between two groups
      groupPad: 3 # Padding inside groups
      itemMargin: 3 # Vertical space between two items
      labelPad: 3 # Padding above text labels
      labelMargin: 6 # Horizontal space around labels for push buttons and switches
      unit: unit = 32
      thumbSize: unit - 4
      colUnits: colUnits = 5
      colInnerWidth: colInnerWidth = unit * colUnits # Width of items in a column
    Settings:
      unit: 32
      itemWidth: 300
      itemMargin: 8 # Vertical space between two items
      panelPad: 8
      panelBorderRadius: 8
