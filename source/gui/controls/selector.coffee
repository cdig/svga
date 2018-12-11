Take ["Registry", "GUI", "SelectorButton", "Scope", "SVG"], (Registry, {ControlPanel:GUI}, SelectorButton, Scope, SVG)->
  idCounter = 0

  Registry.set "Control", "selector", (elm, props)->
    id = "Selector#{idCounter++}"

    buttons = []
    activeButton = null

    if props.name?
      # Remember: SVG text element position is ALWAYS relative to the text baseline.
      # So, we position our baseline a certain distance from the top, based on the font size.
      labelY = GUI.labelPad + (props.fontSize or 16) * 0.75 # Lato's baseline is about 75% down from the top of the caps
      labelHeight = GUI.labelPad + (props.fontSize or 16) * 1.2 # Lato's descenders are about 120% down from the top of the caps
    else
      labelHeight = 0

    height = labelHeight + GUI.unit

    labelFill = props.fontColor or "hsl(220, 10%, 92%)"
    borderFill = "rgb(34, 46, 89)"

    clip = SVG.create "clipPath", SVG.defs, id: id
    clipRect = SVG.create "rect", clip,
      x: 2
      y: 2
      width: GUI.colInnerWidth - 4
      height: GUI.unit - 4
      rx: GUI.borderRadius
      fill: "#FFF"

    if props.name?
      label = SVG.create "text", elm,
        textContent: props.name
        x: GUI.colInnerWidth/2
        y: labelY
        fontSize: props.fontSize or 16
        fontWeight: props.fontWeight or "normal"
        fontStyle: props.fontStyle or "normal"
        fill: labelFill

    borderRect = SVG.create "rect", elm,
      rx: GUI.borderRadius + 2
      fill: borderFill
      x: 0
      y: labelHeight
      width: GUI.colInnerWidth
      height: GUI.unit

    buttonsContainer = Scope SVG.create "g", elm, clipPath: "url(##{id})"
    buttonsContainer.x = 0
    buttonsContainer.y = labelHeight

    setActive = (unclick)->
      activeButton?()
      activeButton = unclick


    return scope =
      height: height

      button: (props)->
        props.setActive = setActive
        buttonElm = SVG.create "g", buttonsContainer.element
        buttonScope = Scope buttonElm, SelectorButton, props
        buttons.push buttonScope

        buttonWidth = GUI.colInnerWidth / buttons.length
        for button, i in buttons
          button.resize buttonWidth
          button.x = buttonWidth * i

        return buttonScope

      _highlight: (enable)->
        if enable
          SVG.attrs label, fill: "url(#LightHighlightGradient)"
          SVG.attrs borderRect, fill: "url(#DarkHighlightGradient)"
        else
          SVG.attrs label, fill: labelFill
          SVG.attrs borderRect, fill: borderFill
        button._highlight enable for button in buttons
