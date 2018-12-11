Take ["GUI", "Input", "SVG", "Tween"], ({ControlPanel:GUI}, Input, SVG, Tween)->
  active = null

  Make "PopoverButton", (elm, props)->

    handlers = []
    isActive = false
    highlighting = false
    labelFill = props.fontColor or "hsl(227, 16%, 24%)"

    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true


    bg = SVG.create "rect", elm,
      width: GUI.colInnerWidth - GUI.panelPadding*2
      height: GUI.unit
      rx: GUI.groupBorderRadius

    label = SVG.create "text", elm,
      x: GUI.colInnerWidth/2 - GUI.panelPadding
      y: (props.fontSize or 16) + GUI.unit/5
      textContent: props.name
      fill: labelFill
      fontSize: props.fontSize or 16
      fontWeight: props.fontWeight or "normal"
      fontStyle: props.fontStyle or "normal"


    # Setup the bg stroke color for tweening
    curBG = null
    whiteBG  = h:220, s: 10, l: 92
    blueBG   = h:215, s:100, l: 86
    orangeBG = h: 43, s:100, l: 59
    activeBG = h: 92, s: 46, l: 57
    tickBG = (_curBG)->
      curBG = _curBG
      if highlighting and isActive
        SVG.attrs bg, fill: "url(#MidHighlightGradient)"
      else
        SVG.attrs bg, fill: "hsl(#{curBG.h|0},#{curBG.s|0}%,#{curBG.l|0}%)"
    tickBG whiteBG


    # Input event handling
    toNormal   = (e, state)-> Tween curBG, whiteBG, .2, tick:tickBG
    toHover    = (e, state)-> Tween curBG, blueBG,   0, tick:tickBG if not state.touch and not isActive
    toClicking = (e, state)-> Tween curBG, orangeBG, 0, tick:tickBG
    toActive   = (e, state)-> Tween curBG, activeBG,  .2, tick:tickBG
    unclick = ()->
      toNormal()
      isActive = false
    click = (e, state)->
      props.setActive props.name, unclick
      isActive = true
      toActive()
      handler() for handler in handlers
      undefined
    input = Input elm,
      moveIn:  (e, state)->    toHover e, state unless isActive
      dragIn:  (e, state)-> toClicking e, state if state.clicking and !isActive
      down:    (e, state)-> toClicking e, state unless isActive
      up:      (e, state)->    toHover e, state unless isActive
      moveOut: (e, state)->   toNormal e, state unless isActive
      dragOut: (e, state)->   toNormal e, state unless isActive
      click:   (e, state)->      click e, state unless isActive


    # Set up click handling
    attachClick = (cb)-> handlers.push cb
    attachClick props.click if props.click?

    Take "SceneReady", ()->
      click() if props.active

    return scope =
      click: attachClick
      input: input

      _highlight: (enable)->
        if highlighting = enable
          SVG.attrs label, fill: "black"
        else
          SVG.attrs label, fill: labelFill
        tickBG curBG
