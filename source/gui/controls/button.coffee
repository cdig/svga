Take ["Control","GUI","Input","SVG","TRS","Tween"],
(      Control , GUI , Input , SVG , TRS , Tween)->
  
  Control "button", (elm, props)->
    handlers = []
    u = GUI.ControlPanel.unit
    
    bg = TRS SVG.create "rect", elm,
      fill:"hsl(220, 12%, 80%)"
      rx: 0
      ry: 0
    
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "hsl(220, 0%, 30%)"
    
    w = label.getComputedTextLength()
    h =
    
    c = 1
    tickBG = (v)->
      c = v
      SVG.attrs bg, fill: "hsl(220, 12%, #{v*80}%)"
    
    depress = ()-> Tween c, 0.9, 0, tickBG
    release = ()-> Tween c, 1, .2, tickBG
    
    Input elm,
      click: ()-> handler() for handler in handlers
      down: depress
      drag: depress
      out: release
      up: release
    
    
    return scope =
      attach: (props)->
        handlers.push props.action if props.action?
      
      preferredSize: ()->
        
      
      resize: (w, h)->
        SVG.attrs bg,
          width: w
          height: h
        
        SVG.attrs label,
          x: w/2
          y: h/2 + 8
