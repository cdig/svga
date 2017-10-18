Take ["GUI", "Input", "Registry", "SVG", "Tween"], ({ControlPanel:GUI}, Input, Registry, SVG, Tween)->
  Registry.set "Control", "pushButton", (elm, props)->
    
    # Arrays to hold all the functions that have been attached to this control
    onHandlers = []
    offHandlers = []
    
    radius = GUI.unit * 0.6
    height = radius * 2
    
    bgFill = "hsl(220, 10%, 92%)"
    labelFill = "hsl(220, 10%, 92%)"
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    # Group background element
    groupBg = SVG.create "rect", elm,
      x: -GUI.groupPad
      y: -GUI.groupPad
      width: GUI.colInnerWidth + GUI.groupPad*2
      height: radius*2 + GUI.groupPad*2
      rx: GUI.groupBorderRadius
      fill: props.group or "transparent"
    
    # Button background element
    bg = SVG.create "circle", elm,
      cx: radius
      cy: radius
      r: radius
      strokeWidth: 2
      fill: bgFill
    
    # Button text label
    label = SVG.create "text", elm,
      textContent: props.name
      x: radius*2 + 6
      y: radius + (props.fontSize or 16) * 0.36
      textAnchor: "start"
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
    toNormal   = (e, state)-> Tween bgc, blueBG,  .2, tick:tickBG
    toHover    = (e, state)-> Tween bgc, lightBG,  0, tick:tickBG
    toClicking = (e, state)-> Tween bgc, orangeBG, 0, tick:tickBG
    Input elm,
      moveIn: toHover
      down: ()->
        toClicking()
        onHandler() for onHandler in onHandlers
        undefined
      up: ()->
        toHover()
        offHandler() for offHandler in offHandlers
        undefined
      miss: ()->
        toNormal()
        offHandler() for offHandler in offHandlers
        undefined
      moveOut: toNormal
    
    
    # Our scope just has the 3 mandatory control functions, nothing special.
    return scope =
      height: height
      
      attach: (props)->
        onHandlers.push props.on if props.on?
        offHandlers.push props.off if props.off?
      
      _highlight: (enable)->
        if enable
          SVG.attrs bg, fill: "url(#LightHighlightGradient)"
          SVG.attrs label, fill: "black"
        else
          SVG.attrs bg, fill: bgFill
          SVG.attrs label, fill: labelFill
