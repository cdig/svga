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
    
    # The thumb graphic
    thumbBG = SVG.create "rect", thumb,
      x: GUI.pad
      y: GUI.pad
      strokeWidth: 2
      fill: "hsl(220, 10%, 92%)"
    
    # The text label in the thumb
    label = SVG.create "text", thumb,
      textContent: props.name
      fill: "hsl(227, 16%, 24%)"
      y: GUI.unit/2 + 6
    
    
    # Pre-compute some size info that will be used later for layout
    labelWidth = Math.max GUI.unit, label.getComputedTextLength() + GUI.pad*8
    
    
    # Size and position the thumb
    SVG.attrs thumbBG, width: labelWidth
    SVG.attrs label, x: GUI.pad + labelWidth/2
    
    
    # Setup the thumbBG stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    bgFill = (_bgc)->
      bgc = _bgc
      SVG.attrs thumbBG, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    bgFill blueBG
    
    
    # Update and save the thumb position
    update = (V)->
      v = Math.max 0, Math.min 1, V if V?
      TRS.abs thumb, x: v * range
    
    
    # Input event handling
    toNormal   = ()-> Tween bgc, blueBG,  .2, tick:bgFill
    toHover    = ()-> Tween bgc, lightBG,  0, tick:bgFill
    toClicking = ()-> Tween bgc, orangeBG, 0, tick:bgFill
    toClicked  = ()-> Tween bgc, lightBG, .2, tick:bgFill
    toMissed   = ()-> Tween bgc, blueBG, .2, tick:bgFill
    handleDrag = (e)->
      update e.clientX/range - startDrag
      handler v for handler in handlers
    Input elm,
      moveIn: toHover
      dragIn: (e, state)-> toClicking() if state.clicking
      down: (e)->
        toClicking()
        startDrag = e.clientX/range - v
      moveOut: toNormal
      miss: toMissed
      drag: handleDrag
      dragOther: (e, state)->
        handleDrag e if state.clicking
      click: toClicked
    
    
    return scope =
      attach: (props)->
        handlers.push props.change if props.change?
        update props.value if props.value?
      
      getPreferredSize: ()-> w:GUI.width, h:GUI.unit
      
      resize: ({w:w, h:h})->
        range = w - GUI.pad*2 - labelWidth
        update()
        SVG.attrs track,
          width: w - GUI.pad*2
          height: h - GUI.pad*2
          rx: (h - GUI.pad*2)/2
        SVG.attrs thumbBG,
          height: h - GUI.pad*2
          rx: (h - GUI.pad*2)/2
        return w:w, h:h
