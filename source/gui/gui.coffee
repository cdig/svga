Take ["SVG", "SVGReady"], (SVG)->
  Make "GUI", GUI =
    elm: SVG.create "g", SVG.svg, xGui:""
    ControlPanel:
      width: 200
      unit: 42
      pad: 3
      borderRadius: 4
      panelBorderRadius: 10
      panelMargin: 10
      bg: "hsl(220, 45%, 45%)"
