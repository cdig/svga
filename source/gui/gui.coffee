Take ["SVG", "SVGReady"], (SVG)->
  Make "GUI", GUI =
    elm: SVG.create "g", SVG.svg, xGui:""
    ControlPanel:
      width: 200
      unit: 42
      pad: 3
      borderRadius: 4
      light: "hsl(220, 45%, 50%)"
      dark: "hsl(227, 45%, 35%)"
