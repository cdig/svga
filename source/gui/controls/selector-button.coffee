Take ["GUI", "Input", "SVG", "Tween"], ({ControlPanel:GUI}, Input, SVG, Tween)->
  active = null
  
  Make "SelectorButton", (elm, props)->
    
    handlers = []
    isActive = false
    highlighting = false
    labelFill = "hsl(227, 16%, 24%)"
    strokeWidth = 2
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    
    bg = SVG.create "rect", elm,
      x: strokeWidth/2
      y: strokeWidth/2
      height: GUI.unit - strokeWidth
    
    label = SVG.create "text", elm,
      y: (props.fontSize or 16) + GUI.unit/5
      textContent: props.name
      fill: labelFill
      fontSize: props.fontSize or 16
      fontWeight: props.fontWeight or "normal"
      fontStyle: props.fontStyle or "normal"
    
    
    # Setup the bg stroke color for tweening
    curBG = whiteBG = r:233, g:234, b:237
    lightBG = r:142, g:196, b:96
    orangeBG = r:255, g:196, b:46
    blueBG = r:183, g:213, b:255
    tickBG = (_curBG)->
      curBG = _curBG
      if highlighting and isActive
        SVG.attrs bg, fill: "url(#MidHighlightGradient)"
      else
        SVG.attrs bg, fill: "rgb(#{curBG.r|0},#{curBG.g|0},#{curBG.b|0})"
    tickBG whiteBG
    
    
    # Input event handling
    toNormal   = (e, state)-> Tween curBG, whiteBG, .2, tick:tickBG
    toHover    = (e, state)-> Tween curBG, blueBG,   0, tick:tickBG if not state.touch and not isActive
    toClicking = (e, state)-> Tween curBG, orangeBG, 0, tick:tickBG
    toActive   = (e, state)-> Tween curBG, lightBG,  .2, tick:tickBG
    unclick = ()->
      toNormal()
      isActive = false
    click = (e, state)->
      props.setActive unclick
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
      
      resize: (width)->
        SVG.attrs bg, width: width - strokeWidth
        SVG.attrs label, x: width/2
      
      _highlight: (enable)->
        if highlighting = enable
          SVG.attrs label, fill: "black"
        else
          SVG.attrs label, fill: labelFill
        tickBG curBG
