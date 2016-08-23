Take ["Registry", "GUI", "SelectorButton", "Scope", "SVG"], (Registry, {ControlPanel:GUI}, SelectorButton, Scope, SVG)->
  idCounter = 0
  
  Registry.set "Control", "selector", (elm, props)->
    id = "Selector#{idCounter++}"
    labelHeight = 0
    preferredSize =
      w:GUI.pad*2
      h:GUI.unit
    buttons = []
    activeButton = null
    buttonPreferredSizes = []
    
    
    clip = SVG.create "clipPath", SVG.defs, id: id
    clipRect = SVG.create "rect", clip,
      rx: GUI.borderRadius
      fill: "#FFF"
    
    if props.name?
      label = SVG.create "text", elm,
        textContent: props.name
        fontSize: 16
        fill: "hsl(220, 10%, 92%)"
      preferredSize.h += labelHeight = 22
    
    borderRect = SVG.create "rect", elm,
      rx: GUI.borderRadius + 2
      fill: "rgb(34, 46, 89)"
    
    buttonsContainer = Scope SVG.create "g", elm, clipPath: "url(##{id})"
    buttonsContainer.x = GUI.pad
    buttonsContainer.y = labelHeight
    
    
    setActive = (unclick)->
      activeButton?()
      activeButton = unclick
    
    
    return scope =
      button: (props)->
        props.setActive = setActive
        buttonElm = SVG.create "g", buttonsContainer.element
        buttonScope = Scope buttonElm, SelectorButton, props
        buttons.push buttonScope
        bps = buttonScope.getPreferredSize()
        buttonPreferredSizes.push bps
        preferredSize.w += bps.w
        return buttonScope
      
      getPreferredSize: ()->
        xOffset = 0
        for button in buttons
          button.x = xOffset
          xOffset += button.resize 1, xOffset

        size =
          w:xOffset
          h:GUI.unit + labelHeight
      
      resize: ({w:w, h:h})->
        innerWidth = w - GUI.pad*2
        innerHeight = h - GUI.pad*2
        upscale = w/preferredSize.w
        
        xOffset = 0
        for button in buttons
          button.x = xOffset
          xOffset += button.resize upscale, xOffset
        
        SVG.attrs clipRect,
          x: 1
          y: GUI.pad + 1
          width: innerWidth - 2
          height: GUI.unit - GUI.pad*2 - 2
        
        SVG.attrs borderRect,
          x: GUI.pad - 1
          y: GUI.pad + labelHeight - 1
          width: innerWidth + 2
          height: GUI.unit - GUI.pad*2 + 2
        
        if label?
          SVG.attrs label,
            x: w/2
            y: 18
        
        return w:w, h:h
