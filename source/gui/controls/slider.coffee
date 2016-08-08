Take ["Control", "GUI", "Input", "SVG", "TRS", "Tween"], (Control, {ControlPanel:GUI}, Input, SVG, TRS, Tween)->
  Control "slider", (elm, props)->
    
    # An array to hold all the change functions that have been attached to this slider
    handlers = []
    
    # Some local variables used to manage the slider position
    v = 0
    range = 0
    startDrag = 0
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true

    # Slider background element
    track = TRS SVG.create "rect", elm,
      x: GUI.pad
      y: GUI.pad
      strokeWidth: 2
      fill: "hsl(227, 45%, 24%)"
      stroke: "hsl(227, 45%, 24%)"
    
    # A container element for the draggable slider thumb
    thumb = TRS SVG.create "g", elm
    
    thumbBG = SVG.create "rect", thumb,
      x: GUI.pad
      y: GUI.pad
      strokeWidth: 2
      fill: "hsl(220, 10%, 92%)"
    
    label = SVG.create "text", thumb,
      textContent: props.name
      fill: "hsl(227, 16%, 24%)"
      y: GUI.unit/2 + 6
    
    labelWidth = Math.max GUI.unit, label.getComputedTextLength() + GUI.pad*8
    SVG.attrs thumbBG, width: labelWidth
    SVG.attrs label, x: GUI.pad + labelWidth/2

    # Setup the bg stroke color for tweening
    blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    bgFill = ({r:r,g:g,b:b})-> SVG.attrs thumbBG, stroke: "rgb(#{r|0},#{g|0},#{b|0})"
    bgFill blueBG

    
    update = (V)->
      v = V
      TRS.abs thumb, x: v * range
    
    
    Input elm,
      over: ()-> bgFill lightBG
      down: (e)->
        startDrag = e.clientX/range - v
        bgFill orangeBG
      out: (e, state)-> Tween lightBG, blueBG, .1, tick:bgFill if not state.down
      miss: ()-> Tween orangeBG, blueBG, .1, tick:bgFill
      drag: (e)->
        update Math.max 0, Math.min 1, e.clientX/range - startDrag
        handler v for handler in handlers
      click: ()-> Tween orangeBG, lightBG, .2, tick:bgFill
    
    
    return scope =
      set: update
        
      
      attach: (props)->
        handlers.push props.change if props.change?
      
      getPreferredSize: ()-> w:GUI.width, h:GUI.unit
      
      resize: ({w:w, h:h})->
        range = w - GUI.pad*2 - labelWidth
        SVG.attrs track,
          width: w - GUI.pad*2
          height: h - GUI.pad*2
          rx: (h - GUI.pad*2)/2
        SVG.attrs thumbBG,
          height: h - GUI.pad*2
          rx: (h - GUI.pad*2)/2
        return w:w, h:h
