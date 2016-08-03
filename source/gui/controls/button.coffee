Take ["Control", "GUI", "Input", "Scope", "SVG", "Tween"], (Control, GUI, Input, Scope, SVG, Tween)->
  gui = GUI.ControlPanel

  Control "button", (elm, props)->
    handlers = []
    
    SVG.attrs elm, ui: true
    
    bg = Scope SVG.create "rect", elm,
      fill:"hsl(220, 12%, 80%)"
      x: gui.pad
      y: gui.pad
      rx: gui.borderRadius
    
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "hsl(220, 0%, 30%)"

    depress = ()-> Tween bg, {alpha:0.9}, 0
    release = ()-> bg.alpha=0.8; Tween bg, {alpha:1}, .2
    
    Input elm,
      click: ()-> handler() for handler in handlers
      down: depress
      drag: depress
      up: release
    
    # w = label.getComputedTextLength()
    # h = 10
    
    return scope =
      attach: (props)-> handlers.push props.action if props.action?
      preferredSize: ()-> w:w, h:h
      resize: (w, h)->
        SVG.attrs bg.element, width:w-gui.pad*2, height:h-gui.pad*2
        SVG.attrs label, x: w/2, y: h/2 + 8
