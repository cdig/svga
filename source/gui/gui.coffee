Take ["SVG", "SVGReady"], (SVG)->
  Make "GUI", GUI =
    elm: SVG.create "g", SVG.root, xGui:""
    TopBar:
      buttonPadCustom: 16
      buttonPadStandard: 24
      height: 48
      iconPad: 6
      Help:
        inset: 88
      Menu:
        inset: -4
      Settings:
        inset: 200
    ControlPanel:
      width: 240
      unit: 48
      pad: 2
      borderRadius: 4
