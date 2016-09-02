Take ["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], (Registry, {ControlPanel:GUI}, Input, SVG, TRS, Tween)->
  Registry.set "Control", "slider", (elm, props)->
    
    # An array to hold all the change functions that have been attached to this slider
    handlers = []
    
    # Some local variables used to manage the slider position
    v = 0
    range = 0
    startDrag = 0

    trackFill = "hsl(227, 45%, 24%)"
    thumbBGFill = "hsl(220, 10%, 92%)"
    labelFill = "hsl(227, 16%, 24%)"

    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    
    # Slider background element
    track = TRS SVG.create "rect", elm,
      x: GUI.pad
      y: GUI.pad
      strokeWidth: 2
      fill: trackFill
      stroke: "hsl(227, 45%, 24%)"
    
    # A container element for the draggable slider thumb
    thumb = TRS SVG.create "g", elm
    
    # The thumb graphic
    thumbBG = SVG.create "rect", thumb,
      x: GUI.pad
      y: GUI.pad
      strokeWidth: 2
      fill: thumbBGFill
    
    # The text label in the thumb
    label = SVG.create "text", thumb,
      textContent: props.name
      fill: labelFill
    
    
    # Setup the thumbBG stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    tickBG = (_bgc)->
      bgc = _bgc
      SVG.attrs thumbBG, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    tickBG blueBG
    
    
    # Update and save the thumb position
    update = (V)->
      v = Math.max 0, Math.min 1, V if V?
      TRS.abs thumb, x: v * range
    
    
    # Input event handling
    toNormal   = (e, state)-> Tween bgc, blueBG,  .2, tick:tickBG
    toHover    = (e, state)-> Tween bgc, lightBG,  0, tick:tickBG if not state.touch
    toClicking = (e, state)-> Tween bgc, orangeBG, 0, tick:tickBG
    toClicked  = (e, state)-> Tween bgc, lightBG, .2, tick:tickBG
    toMissed   = (e, state)-> Tween bgc, blueBG, .2, tick:tickBG
    handleDrag = (e, state)->
      if state.clicking
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
      dragOther: handleDrag
      click: toClicked
    
    
    return scope =
      attach: (props)->
        handlers.push props.change if props.change?
        update props.value if props.value?
      
      getPreferredSize: ()->
        return size =
          w:GUI.width
          h:GUI.unit
      
      resize: (size)->
        # Recompute the label length on every resize, because the font may have changed
        labelWidth = Math.max GUI.unit, label.getComputedTextLength() + GUI.pad*8
        height = Math.min GUI.unit, size.h
        range = size.w - GUI.pad*2 - labelWidth
        update()
        
        SVG.attrs track,
          width: size.w - GUI.pad*2
          height: height - GUI.pad*2
          rx: (height - GUI.pad*2)/2
        
        SVG.attrs thumbBG,
          width: labelWidth
          height: height - GUI.pad*2
          rx: (height - GUI.pad*2)/2
        
        SVG.attrs label,
          x: GUI.pad + labelWidth/2
          y: height/2 + 6

        return w:size.w, h:height

      _highlight: (enable)->
        if enable
          SVG.attrs track, fill: "url(#DarkHighlightGradient)"
          SVG.attrs thumbBG, fill: "url(#LightHighlightGradient)"
          SVG.attrs label, fill: "black"
        else
          SVG.attrs track, fill: trackFill
          SVG.attrs thumbBG, fill: thumbBGFill
          SVG.attrs label, fill: labelFill
