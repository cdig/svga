Take ["Control", "GUI", "Input", "Scope", "SVG", "Tween"], (Control, GUI, Input, Scope, SVG, Tween)->
  gui = GUI.ControlPanel

  Control "button", (elm, props)->
    handlers = []
    
    SVG.attrs elm, ui: true
    
    bg = Scope SVG.create "rect", elm,
      x: gui.pad
      y: gui.pad
      rx: gui.borderRadius
    
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "hsl(220, 0%, 30%)"
    
    bgFill = (v)-> SVG.attrs bg.element, fill: "hsl(220,12%,#{v*80}%)"
    bgFill 1
    
    depress = ()-> Tween 1, .9, .2, bgFill
    release = ()-> Tween .8, 1, .2, bgFill
    
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
