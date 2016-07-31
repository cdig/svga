Take ["Control","GUI","Input","SVG","TRS","Tween"],
(      Control , GUI , Input , SVG , TRS , Tween)->

  Control "slider", (elm, props)->
    handlers = []
    u = GUI.ControlPanel.unit
    v = 0
    range = u*2
    startDrag = 0
    
    
    track = TRS SVG.create "rect", elm,
      fill:"hsl(220, 12%, 14%)"
      stroke:"hsl(220, 12%, 42%)"
      "stroke-width": 1
      x: 0.5
      y: 0.5
      rx: u/2
      ry: u/2

    thumb = TRS SVG.create "g", elm
    
    thumbBG = SVG.create "rect", thumb,
      fill: "hsl(220, 12%, 30%)"
      "stroke-width":1
      x: 1.5
      y: 1.5
      rx: u/2 - 1
      ry: u/2 - 1
      width: u*2 - 2
      height: u - 2
    
    label = SVG.create "text", thumb,
      textContent: props.name
      fill: "white"
      x: u
      y: u/2 + 8
    
    c = 1
    tickBG = (v)->
      c = v
      SVG.attrs thumbBG, fill: "hsl(220, 12%, #{v*30}%)"
    
    depress = ()-> Tween c, 1.4, 0, tickBG
    release = ()-> Tween c, 1, .2, tickBG
    
    update = (V)->
      v = V
      TRS.abs thumb, x: v * range
    
    Input elm,
      down: (e)->
        startDrag = e.clientX/range - v
        depress()
      drag: (e)->
        update Math.max 0, Math.min 1, e.clientX/range - startDrag
        handler v for handler in handlers
      up: release
    
    return scope =
      w: props.w or 4
      h: props.h or 1
      
      attach: (props)->
        handlers.push props.change if props.change?
      
      resize: (w, h)->
        range = w - u*2
        
        SVG.attrs track,
          width: w
          height: h
      
      set: update
