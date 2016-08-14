Take ["GUI", "Input", "SVG", "Tween"], ({ControlPanel:GUI}, Input, SVG, Tween)->
  Make "SelectorButton", (elm, props)->
    
    preferredSize =
      w:null
      h:GUI.unit
    handlers = []
    
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    
    bg = SVG.create "rect", elm,
      fill: "hsl(220, 10%, 92%)"
    
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "hsl(227, 16%, 24%)"
    
    
    preferredSize.w = Math.max GUI.unit, label.getComputedTextLength() + GUI.pad*8
    
    
    # Setup the bg stroke color for tweening
    # bgc = blueBG = r:34, g:46, b:89
    # lightBG = r:133, g:163, b:224
    # orangeBG = r:255, g:196, b:46
    # bgFill = (_bgc)->
    #   bgc = _bgc
    #   unless scope?.highlightActive
    #     SVG.attrs bg, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    # bgFill blueBG
    
    
    # Input event handling
    toNormal   = (e, state)-> Tween bgc, blueBG,  .2, tick:bgFill
    toHover    = (e, state)-> Tween bgc, lightBG,  0, tick:bgFill if not state.touch
    toClicking = (e, state)-> Tween bgc, orangeBG, 0, tick:bgFill
    toClicked  = (e, state)-> Tween bgc, lightBG, .2, tick:bgFill
    Input elm,
    #   moveIn: toHover
    #   dragIn: (e, state)-> toClicking() if state.clicking
    #   down: toClicking
    #   up: toHover
    #   moveOut: toNormal
    #   dragOut: toNormal
      click: ()->
        # toClicked()
        handler() for handler in handlers
    
    
    # Set up click handling
    attachClick = (cb)-> handlers.push cb
    attachClick props.click if props.click?
    
    
    return scope =
      click: attachClick
      
      getPreferredSize: ()->
        preferredSize
      
      resize: (upscale)->
        innerWidth = preferredSize.w * upscale
        innerHeight = preferredSize.h - GUI.pad*2
        
        SVG.attrs bg,
          x: 1
          y: 1
          width: innerWidth - 2
          height: innerHeight - 2
        
        SVG.attrs label,
          x: innerWidth/2 + GUI.pad
          y: preferredSize.h/2 + 6
        
        return innerWidth
