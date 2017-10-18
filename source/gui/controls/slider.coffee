Take ["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], (Registry, {ControlPanel:GUI}, Input, SVG, TRS, Tween)->
  Registry.set "Control", "slider", (elm, props)->
    
    # An array to hold all the change functions that have been attached to this slider
    handlers = []
    
    # Some local variables used to manage the slider position
    v = 0
    startDrag = 0
    
    # Remember: SVG text element position is ALWAYS relative to the text baseline.
    # So, we position our baseline a certain distance from the top, based on the font size.
    labelY = (props.fontSize or 16) - 4 # The -4 is how we adjust the visual position of the text block, independent of font size
    labelHeight = (props.fontSize or 16) * 1.2 # We'll leave a bit of extra room for descenders
    thumbSize = GUI.unit - 4 # The scroll thumb can be a little smaller than our standard unit size, since the entire track is a big honking touch target
    height = labelHeight + thumbSize
    range = GUI.colInnerWidth - thumbSize
    
    trackFill = "hsl(227, 45%, 24%)"
    thumbBGFill = "hsl(220, 10%, 92%)"
    labelFill = "hsl(220, 10%, 92%)"
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    # Group background element
    groupBg = SVG.create "rect", elm,
      x: -GUI.groupPad
      y: -GUI.groupPad
      width: GUI.colInnerWidth + GUI.groupPad*2
      height: height + GUI.groupPad*2
      rx: GUI.groupBorderRadius
      fill: props.group or "transparent"
    
    # Slider background element
    track = TRS SVG.create "rect", elm,
      y: labelHeight
      width: GUI.colInnerWidth
      height: thumbSize
      strokeWidth: 2
      fill: trackFill
      stroke: "hsl(227, 45%, 24%)"
      rx: thumbSize/2
    
    # The thumb graphic
    thumb = TRS SVG.create "circle", elm,
      cx: thumbSize/2
      cy: labelHeight + thumbSize/2
      strokeWidth: 2
      fill: thumbBGFill
      r: thumbSize/2
    
    # The text label
    if props.name?
      label = SVG.create "text", elm,
        textContent: props.name
        x: GUI.colInnerWidth/2
        y: labelY
        fontSize: props.fontSize or 16
        fontWeight: props.fontWeight or "normal"
        fontStyle: props.fontStyle or "normal"
        fill: labelFill
    
    
    # Setup the thumb stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    tickBG = (_bgc)->
      bgc = _bgc
      SVG.attrs thumb, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
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
        undefined
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
      height: height
      
      attach: (props)->
        handlers.push props.change if props.change?
        update props.value if props.value?
      
      _highlight: (enable)->
        if enable
          SVG.attrs track, fill: "url(#DarkHighlightGradient)"
          SVG.attrs thumb, fill: "url(#LightHighlightGradient)"
          SVG.attrs label, fill: "black"
        else
          SVG.attrs track, fill: trackFill
          SVG.attrs thumb, fill: thumbBGFill
          SVG.attrs label, fill: labelFill
