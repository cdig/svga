Take ["GUI", "Input", "Registry", "SVG", "Tween"], ({ControlPanel:GUI}, Input, Registry, SVG, Tween)->
  Registry.set "Control", "button", (elm, props)->
    
    # An array to hold all the click functions that have been attached to this button
    handlers = []
    
    bgFill = "hsl(220, 10%, 92%)"
    labelFill = "hsl(227, 16%, 24%)"
    
    strokeWidth = 2
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    # Button background element
    bg = SVG.create "rect", elm,
      x: strokeWidth/2
      y: strokeWidth/2
      width: GUI.colInnerWidth - strokeWidth
      height: GUI.unit - strokeWidth
      rx: GUI.borderRadius
      strokeWidth: strokeWidth
      fill: bgFill
    
    # Button text label
    label = SVG.create "text", elm,
      textContent: props.name
      x: GUI.colInnerWidth / 2
      y: (props.fontSize or 16) + GUI.unit/5
      width: GUI.colInnerWidth
      fontSize: props.fontSize or 16
      fontWeight: props.fontWeight or "normal"
      fontStyle: props.fontStyle or "normal"
      fill: labelFill
    
    # Setup the bg stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    tickBG = (_bgc)->
      bgc = _bgc
      SVG.attrs bg, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    tickBG blueBG
    
    
    # Input event handling
    blocked = false
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
        # iOS fires 2 click events in rapid succession, so we debounce it here
        return if blocked
        blocked = true
        setTimeout (()-> blocked = false), 100
        
        toClicked()
        handler() for handler in handlers
        undefined
    
    
    # Our scope just has the 3 mandatory control functions, nothing special.
    return scope =
      height: GUI.unit
      
      attach: (props)->
        handlers.push props.click if props.click?
      
      _highlight: (enable)->
        if enable
          SVG.attrs bg, fill: "url(#LightHighlightGradient)"
          SVG.attrs label, fill: "black"
        else
          SVG.attrs bg, fill: bgFill
          SVG.attrs label, fill: labelFill
