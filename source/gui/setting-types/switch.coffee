Take ["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], (Registry, {Settings:GUI}, Input, SVG, TRS, Tween)->
  Registry.set "SettingType", "switch", (elm, props)->

    strokeWidth = 2
    labelPad = 10
    labelWidth = GUI.itemWidth/2
    thumbSize = GUI.unit
    isActive = false
    normalTrack = "hsl(227, 45%, 24%)"
    lightTrack = "hsl(92, 46%, 57%)"

    SVG.attrs elm, ui: true

    track = SVG.create "rect", elm,
      x: strokeWidth/2 + labelWidth
      y: strokeWidth/2
      width: thumbSize * 2 - strokeWidth
      height: thumbSize - strokeWidth
      strokeWidth: strokeWidth
      fill: normalTrack
      stroke: normalTrack
      rx: thumbSize/2

    thumb = TRS SVG.create "circle", elm,
      cx: thumbSize/2 + labelWidth
      cy: thumbSize/2
      strokeWidth: strokeWidth
      fill: "hsl(220, 10%, 92%)"
      r: thumbSize/2 - strokeWidth/2

    label = SVG.create "text", elm,
      textContent: props.name
      x: labelWidth - labelPad
      y: 21
      textAnchor: "end"
      fill: "hsl(220, 10%, 92%)"



    toggle = ()->
      isActive = !isActive
      TRS.abs thumb, x: if isActive then thumbSize else 0
      SVG.attrs track, fill: if isActive then lightTrack else normalTrack
      props.update isActive


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
    Input elm,
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

    # Init
    toggle() if props.value

    return scope =
      isActive: ()-> isActive
      setValue: (v = null)->
        if not v? or v isnt isActive
          toggle()
