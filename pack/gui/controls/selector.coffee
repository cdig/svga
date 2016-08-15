Take ["Control", "GUI", "SelectorButton", "Scope", "SVG"], (Control, {ControlPanel:GUI}, SelectorButton, Scope, SVG)->
  idCounter = 0

  Control "selector", (elm, props)->
    id = "Selector#{idCounter++}"
    labelHeight = 0
    preferredSize =
      w:GUI.pad*2
      h:GUI.unit
    buttons = []
        
    
    # Clip path
    clip = SVG.create "clipPath", SVG.defs, id: id
    rect = SVG.create "rect", clip,
      rx: GUI.borderRadius
      fill: "#FFF"
    
    # The name label above the control
    if props.name?
      label = SVG.create "text", elm,
        textContent: props.name
        fontSize: 18
        fill: "hsl(220, 10%, 92%)"
      preferredSize.h += labelHeight = 22
    
    
    buttonsContainer = Scope SVG.create "g", elm#, clipPath: "url(##{id})"
    buttonsContainer.x = 1
    buttonsContainer.y = labelHeight + 1
    
    rect2 = SVG.create "rect", buttonsContainer.element,
      rx: GUI.borderRadius
      fill: "#F0F"
      fillOpacity: 0.5

    
    return scope =
      button: (props)->
        buttonElm = SVG.create "g", buttonsContainer.element
        buttonScope = Scope buttonElm, SelectorButton, props
        preferredSize.w += buttonScope.getPreferredSize().w
        buttons.push buttonScope
        return buttonScope
      
      getPreferredSize: ()->
        size =
          w:GUI.width
          h:GUI.unit + labelHeight
      
      resize: ({w:w, h:h})->
        innerWidth = 200# - GUI.pad*2 # HACK
        innerHeight = h - GUI.pad*2
        upscale = innerWidth/preferredSize.w
        
        xOffset = GUI.pad
        for button in buttons
          button.x = xOffset
          xOffset += button.resize upscale, xOffset
        
        p =
          x: GUI.pad + 1
          y: GUI.pad + 1
          width: innerWidth - 2
          height: innerHeight - 2
        
        SVG.attrs rect, p
        SVG.attrs rect2, p
        
        SVG.attrs label,
          x: 200/2 # HACK
          y: 20
