Take ["Registry", "GUI", "Input", "RAF", "SVG", "TRS", "Tween"], (Registry, {ControlPanel:GUI}, Input, RAF, SVG, TRS, Tween)->
  Registry.set "Control", "switch", (elm, props)->

    # An array to hold all the change functions that have been attached to this slider
    handlers = []
    strokeWidth = 2
    thumbSize = GUI.thumbSize
    trackWidth = thumbSize * 2
    isActive = false
    height = thumbSize

    normalTrack = "hsl(227, 45%, 24%)"
    lightTrack = "hsl(92, 46%, 57%)"
    lightFill = "hsl(220, 10%, 92%)"
    labelFill = props.fontColor or lightFill

    SVG.attrs elm, ui: true

    track = SVG.create "rect", elm,
      x: strokeWidth/2
      y: strokeWidth/2
      width: trackWidth - strokeWidth
      height: thumbSize - strokeWidth
      strokeWidth: strokeWidth
      fill: normalTrack
      stroke: normalTrack
      rx: thumbSize/2

    thumb = TRS SVG.create "circle", elm,
      cx: thumbSize/2
      cy: thumbSize/2
      strokeWidth: strokeWidth
      fill: lightFill
      r: thumbSize/2 - strokeWidth/2

    label = SVG.create "text", elm,
      textContent: props.name
      x: trackWidth + GUI.labelMargin
      y: (props.fontSize or 16) + GUI.unit/16
      fontSize: props.fontSize or 16
      fontWeight: props.fontWeight or "normal"
      fontStyle: props.fontStyle or "normal"
      textAnchor: "start"
      fill: labelFill


    toggle = ()->
      isActive = !isActive
      TRS.abs thumb, x: if isActive then thumbSize else 0
      SVG.attrs track, fill: if isActive then lightTrack else normalTrack
      props.click isActive


    # Setup the thumb stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    tickBG = (_bgc)->
      bgc = _bgc
      SVG.attrs thumb, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    tickBG blueBG

    # Input event handling
    toNormal   = (e, state)-> Tween bgc, blueBG,  .2, tick:tickBG
    toHover    = (e, state)-> Tween bgc, lightBG,  0, tick:tickBG if not state.touch
    toClicking = (e, state)-> Tween bgc, orangeBG, 0, tick:tickBG
    toClicked  = (e, state)-> Tween bgc, lightBG, .2, tick:tickBG
    input = Input elm,
      moveIn: toHover
      dragIn: (e, state)-> toClicking() if state.clicking
      down: toClicking
      up: toHover
      moveOut: toNormal
      dragOut: toNormal
      click: ()->
        toClicked()
        toggle()
        undefined

    return scope =
      height: height
      input: input

      isActive: ()-> isActive

      setValue: (v = null)->
        if not v? or v isnt isActive
          toggle()

      attach: (props)->
        handlers.push props.change if props.change?
        RAF toggle, true if props.active

      _highlight: (enable)->
        if enable
          SVG.attrs track, fill: if isActive then "url(#MidHighlightGradient)" else "url(#DarkHighlightGradient)"
          SVG.attrs thumb, fill: "url(#LightHighlightGradient)"
          SVG.attrs label, fill: "url(#LightHighlightGradient)"
        else
          SVG.attrs track, fill: if isActive then lightTrack else normalTrack
          SVG.attrs thumb, fill: lightFill
          SVG.attrs label, fill: labelFill
