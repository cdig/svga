Take ["Registry", "GUI", "Scope", "SVG"], (Registry, {ControlPanel:GUI}, Scope, SVG)->
  Registry.set "Control", "label", (elm, props)->
    
    # Remember: SVG text element position is ALWAYS relative to the text baseline.
    # So, we position our baseline a certain distance from the top, based on the font size.
    labelY = (props.fontSize or 16) * 0.8 # The -4 is how we adjust the visual position of the text block, independent of font size
    height = (props.fontSize or 16) # We'll leave a bit of extra room for descenders
    
    labelFill = "hsl(220, 10%, 92%)"
    
    # Group background element
    groupBg = SVG.create "rect", elm,
      x: -GUI.groupPad
      y: -GUI.groupPad
      width: GUI.colInnerWidth + GUI.groupPad*2
      height: height + GUI.groupPad*2
      rx: GUI.groupBorderRadius
      fill: props.group or "transparent"
    
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
