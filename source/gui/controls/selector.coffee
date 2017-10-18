Take ["Registry", "GUI", "SelectorButton", "Scope", "SVG"], (Registry, {ControlPanel:GUI}, SelectorButton, Scope, SVG)->
  idCounter = 0
  
  Registry.set "Control", "selector", (elm, props)->
    id = "Selector#{idCounter++}"
    
    buttons = []
    activeButton = null
    
    if props.name?
      # Remember: SVG text element position is ALWAYS relative to the text baseline.
      # So, we position our baseline a certain distance from the top, based on the font size.
      labelY = (props.fontSize or 16) - 6 # The -6 is how we adjust the visual position of the text block, independent of font size
      labelHeight = (props.fontSize or 16) * 1.2 # We'll leave a bit of extra room for descenders
    else
      labelHeight = 0
    
    height = labelHeight + GUI.unit
    
    labelFill = "hsl(220, 10%, 92%)"

    # Group background element
    groupBg = SVG.create "rect", elm,
      x: -GUI.groupPad
      y: -GUI.groupPad
      width: GUI.colInnerWidth + GUI.groupPad*2
      height: height + GUI.groupPad*2
      rx: GUI.groupBorderRadius
      fill: props.group or "transparent"
    
    clip = SVG.create "clipPath", SVG.defs, id: id
    clipRect = SVG.create "rect", clip,
      rx: GUI.borderRadius
      fill: "#FFF"
      
      x: 1
      y: 1
      width: GUI.colInnerWidth - 2
      height: GUI.unit - 2
    
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
      fill: "rgb(34, 46, 89)"
      
      x: -1
      y: labelHeight - 1
      width: GUI.colInnerWidth + 2
      height: GUI.unit + 2
    
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
