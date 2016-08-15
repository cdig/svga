Take ["GUI", "Input", "SVG", "Tween"], ({ControlPanel:GUI}, Input, SVG, Tween)->
  active = null
  
  Make "SelectorButton", (elm, props)->
    
    preferredSize =
      w:null
      h:GUI.unit
    handlers = []
    isActive = false
    
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    
    bg = SVG.create "rect", elm
    
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "hsl(227, 16%, 24%)"
    
    
    preferredSize.w = Math.max GUI.unit, label.getComputedTextLength() + GUI.pad*8
    
    
    # Setup the bg stroke color for tweening
    bgc = whiteBG = r:233, g:234, b:237
    lightBG = r:142, g:196, b:96
    orangeBG = r:255, g:196, b:46
    blueBG = r:183, g:213, b:255
    bgFill = (_bgc)->
      bgc = _bgc
      unless scope?.highlightActive
        SVG.attrs bg, fill: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    bgFill whiteBG
    
    
    # Input event handling
    toNormal   = (e, state)-> Tween bgc, whiteBG, .2, tick:bgFill
    toHover    = (e, state)-> Tween bgc, blueBG,   0, tick:bgFill if not state.touch and not isActive
    toClicking = (e, state)-> Tween bgc, orangeBG, 0, tick:bgFill
    toActive   = (e, state)-> Tween bgc, lightBG,  .2, tick:bgFill
    unclick = ()->
      toNormal()
      isActive = false
    click = (e, state)->
      active?()
      active = unclick
      isActive = true
      toActive()
      handler() for handler in handlers
    Input elm,
      moveIn: (e, state)-> toHover e, state unless isActive
      dragIn: (e, state)-> toClicking e, state if state.clicking and !isActive
      down: (e, state)-> toClicking e, state unless isActive
      up: (e, state)-> toHover e, state unless isActive
      moveOut: (e, state)-> toNormal e, state unless isActive
      dragOut: (e, state)-> toNormal e, state unless isActive
      click: (e, state)-> click e, state unless isActive
    
    
    # Set up click handling
    attachClick = (cb)-> handlers.push cb
    attachClick props.click if props.click?
    
    Take "ScopeReady", ()->
      click() if props.active
    
    return scope =
      click: attachClick
      
      getPreferredSize: ()->
        preferredSize
      
      resize: (upscale)->
        innerWidth = Math.ceil preferredSize.w * upscale
        innerHeight = preferredSize.h - GUI.pad*2
        
        SVG.attrs bg,
          x: 1
          y: GUI.pad + 1
          width: innerWidth - 2
          height: innerHeight - 2
        
        SVG.attrs label,
          x: innerWidth/2
          y: innerHeight/2 + 6 + GUI.pad
        
        return innerWidth
