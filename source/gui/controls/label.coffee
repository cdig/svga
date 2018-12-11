Take ["Registry", "GUI", "Scope", "SVG"], (Registry, {ControlPanel:GUI}, Scope, SVG)->
  Registry.set "Control", "label", (elm, props)->

    # Remember: SVG text element position is ALWAYS relative to the text baseline.
    # So, we position our baseline a certain distance from the top, based on the font size.
    labelY = GUI.labelPad + (props.fontSize or 16) * 0.75 # Lato's baseline is about 75% down from the top of the caps
    height = GUI.labelPad + (props.fontSize or 16)

    labelFill = props.fontColor or "hsl(220, 10%, 92%)"

    label = SVG.create "text", elm,
      textContent: props.name
      x: GUI.colInnerWidth/2
      y: labelY
      fontSize: props.fontSize or 16
      fontWeight: props.fontWeight or "normal"
      fontStyle: props.fontStyle or "normal"
      fill: labelFill

    return scope =
      height: height
