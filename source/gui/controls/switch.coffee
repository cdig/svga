Take ["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], (Registry, {ControlPanel:GUI}, Input, SVG, TRS, Tween)->
  Registry.set "Control", "switch", (elm, props)->
    
    # An array to hold all the change functions that have been attached to this slider
    handlers = []
    strokeWidth = 2
    thumbSize = GUI.thumbSize
    trackWidth = thumbSize * 2
    active = false
    height = thumbSize
    
    normalTrack = "hsl(227, 45%, 24%)"
    lightTrack = "hsl(92, 46%, 57%)"
    
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
      fill: "hsl(220, 10%, 92%)"
      r: thumbSize/2 - strokeWidth/2
    
    label = SVG.create "text", elm,
      textContent: props.name
      x: trackWidth + GUI.labelMargin
      y: 21
      textAnchor: "start"
      fill: "hsl(220, 10%, 92%)"
    
    
    toggle = ()->
      active = !active
      TRS.abs thumb, x: if active then thumbSize else 0
      SVG.attrs track, fill: if active then lightTrack else normalTrack
      cb active
    
    
    # Setup the thumb stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    tickBG = (_bgc)->
      bgc = _bgc
      SVG.attrs thumb, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
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
        toggle()
        undefined
    
    return scope =
      height: height
      
      attach: (props)->
        handlers.push props.change if props.change?
        toggle() if props.active
      
      # _highlight: (enable)->
      #   if enable
      #     SVG.attrs track, fill: "url(#DarkHighlightGradient)"
      #     SVG.attrs thumb, fill: "url(#LightHighlightGradient)"
      #     SVG.attrs label, fill: "url(#LightHighlightGradient)"
      #   else
      #     SVG.attrs track, fill: trackFill
      #     SVG.attrs thumb, fill: thumbBGFill
      #     SVG.attrs label, fill: labelFill
