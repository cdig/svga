Take ["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], (Registry, {Settings:GUI}, Input, SVG, TRS, Tween)->
  Registry.set "SettingType", "slider", (elm, props)->

    snapElms = []
    
    v = 0
    startDrag = 0
    strokeWidth = 2
    snapTolerance = 0.05
    labelPad = 10
    
    labelWidth = GUI.itemWidth/2
    trackWidth = GUI.itemWidth - labelWidth
    thumbSize = GUI.unit
    range = trackWidth - thumbSize

    lightDot = "hsl(92, 46%, 57%)"
    normalDot = "hsl(220, 10%, 92%)"
    
    SVG.attrs elm, ui: true
    
    track = SVG.create "rect", elm,
      x: strokeWidth/2 + labelWidth
      y: strokeWidth/2
      width: trackWidth - strokeWidth
      height: thumbSize - strokeWidth
      strokeWidth: strokeWidth
      fill: "hsl(227, 45%, 24%)"
      stroke: "hsl(227, 45%, 24%)"
      rx: thumbSize/2
    
    thumb = TRS SVG.create "circle", elm,
      cx: thumbSize/2 + labelWidth
      cy: thumbSize/2
      strokeWidth: strokeWidth
      fill: "hsl(220, 10%, 92%)"
      r: thumbSize/2 - strokeWidth/2
    
    if props.snaps?
      snapElms = for snap in props.snaps
        SVG.create "circle", elm,
          cx: thumbSize/2 + labelWidth + (trackWidth - thumbSize) * snap
          cy: thumbSize/2
          fill: "transparent"
          strokeWidth: 4

    label = SVG.create "text", elm,
      textContent: props.name
      x: labelWidth - labelPad
      y: 21
      textAnchor: "end"
      fill: "hsl(220, 10%, 92%)"
    
    
    # Setup the thumb stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    tickBG = (_bgc)->
      bgc = _bgc
      SVG.attrs thumb, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    tickBG blueBG
    
    
    update = (V)->
      v = Math.max 0, Math.min 1, V if V?
      if props.snaps?
        for snap, i in props.snaps
          if v > snap - snapTolerance and v < snap + snapTolerance
            v = snap
            SVG.attrs snapElms[i], r: 3, stroke: lightDot
          else
            SVG.attrs snapElms[i], r: 2, stroke: normalDot
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
        props.update v
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
  
    # Init
    update props.value or 0
