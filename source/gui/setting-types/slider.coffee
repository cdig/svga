Take ["Ease", "GUI", "Input", "SVG", "TRS", "Tween"], (Ease, {Panel:GUI}, Input, SVG, TRS, Tween)->
  Make "SettingsSlider", SettingsSlider = (elm, props)->

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


    updateSnaps = (input)->
      # Reset all snaps
      for snap, i in props.snaps
        SVG.attrs snapElms[i], r: 2, stroke: normalDot

      # Map our input to the right position, move the slider, and highlight the proper dot if needed
      for snap, i in props.snaps

        # Input is inside this snap point
        if input >= snap - snapTolerance and input <= snap + snapTolerance
          SVG.attrs snapElms[i], r: 3, stroke: lightDot
          TRS.abs thumb, x: snap * range
          return snap

        # Input is below this snap point
        else if input < snap - snapTolerance
          TRS.abs thumb, x: input * range
          inMin = if i > 0 then props.snaps[i-1] + snapTolerance else 0
          inMax = snap - snapTolerance
          outMin = if i > 0 then props.snaps[i-1] else 0
          outMax = snap
          return Ease.linear input, inMin, inMax, outMin, outMax

      # Snap is above the last snap point
      TRS.abs thumb, x: input * range
      inMin = props.snaps[props.snaps.length-1] + snapTolerance
      inMax = 1
      outMin = props.snaps[props.snaps.length-1]
      outMax = 1
      return Ease.linear input, inMin, inMax, outMin, outMax

    # Update and save the thumb position
    update = (V)->
      v = Math.max 0, Math.min 1, V if V?
      if props.snaps?
        v = updateSnaps v
      else
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
