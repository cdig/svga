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

    Panel:
      unit: 32
      itemWidth: 360
      itemMargin: 8 # Vertical space between two items
      panelPad: 8 # Space between the sides of the panel and items in the panel
      panelMargin: 16 # Minimum space between the outside of the panel and the edge of the window
      panelBorderRadius: 8

    Colors:
      bg:
        xxl: "hsl(217, 70%, 70%)"
        xl:  "hsl(219, 60%, 57%)"
        l:   "hsl(220, 50%, 50%)"
        m:   "hsl(224, 47%, 45%)"
        d:   "hsl(227, 45%, 40%)"
        xd:  "hsl(230, 50%, 30%)"

      # SHADE
      mist:   "hsl(220, 10%, 92%)"
      silver: "hsl(220, 15%, 80%)"
      grey:   "hsl(220, 9%, 52%)"
      smoke:  "hsl(227, 15%, 25%)"
      tar:    "hsl(233, 30%, 17%)"
      onyx:   "hsl(240, 50%, 5%)"

      # KEY
      red:    "hsl(358, 80%, 55%)"
      orange: "hsl(24, 100%, 60%)"
      yellow: "hsl(43, 100%, 50%)"
      green:  "hsl(130, 85%, 35%)"
      blue:   "hsl(223, 45%, 45%)"
      indigo: "hsl(270, 50%, 58%)"
      violet: "hsl(330, 55%, 50%)"

      # SPECIAL
      blueberry: "hsl(259, 65%, 65%)"
      bronze:    "hsl(43,  50%, 70%)"
      mint:      "hsl(153, 80%, 41%)"
      navy:      "hsl(235, 52%, 22%)"
      navydark:  "hsl(227, 65%, 14%)"
      olive:     "hsl(166, 90%, 20%)"
      purple:    "hsl(255, 49%, 37%)"
      teal:      "hsl(180, 100%, 32%)"
      fuscha:    "hsl(340, 60%, 50%)"
      ghost:     "rgba(255, 255, 255, 0.05)"
      demon:     "rgba(0, 0, 0, 0.05)"
