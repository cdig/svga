Take ["Control","GUI","Input","SVG","TRS","Tween"],
(      Control , GUI , Input , SVG , TRS , Tween)->
  
  Control "button", (elm, props)->
    handlers = []
    enabled = true
    u = GUI.ControlPanel.unit
    
    outerBG = TRS SVG.create "rect", elm,
      fill:"hsl(220, 12%, 30%)"
      stroke:"hsl(220, 12%, 42%)"
      "stroke-width": 1
      x: 0.5
      y: 0.5
      rx: 2
      ry: 2
    
    innerBG = SVG.create "rect", elm,
      fill: "transparent"
      stroke:"hsl(220, 12%, 24%)"
      "stroke-width":1
      x: 1.5
      y: 1.5
      rx: 2
      ry: 2
    
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "white"
    
    c = 1
    tickBG = (v)->
      c = v
      SVG.attrs outerBG, fill: "hsl(220, 12%, #{v*30}%)"
    
    depress = ()-> Tween c, .6, 0, tickBG
    release = ()-> Tween c, 1, .2, tickBG
    
    Input elm,
      click: ()-> handler() for handler in handlers if enabled
      down: depress
      drag: depress
      out: release
      up: release
    
    return scope =
      w: props.w or 2
      h: props.h or 1
      
      attach: (props)->
        handlers.push props.action if props.action?
      
      resize: (w, h)->
        SVG.attrs outerBG,
          width: w
          height: h
        SVG.attrs innerBG,
          width: w - 2
          height: h - 2
        SVG.attrs label,
          x: w/2
          y: h/2 + 8

      disable: ()->
        SVG.attrs elm, disabled: true
        enabled = false
      
      enable: ()->
        SVG.attrs elm, disabled: null
        enabled = true
