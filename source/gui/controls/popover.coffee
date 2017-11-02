Take ["GUI", "Input", "PopoverButton", "RAF", "Registry", "Resize", "Scope", "SVG", "Tween"], ({ControlPanel:GUI}, Input, PopoverButton, RAF, Registry, Resize, Scope, SVG, Tween)->
  Registry.set "Control", "popover", (elm, props)->
    
    # Config
    labelFill = "hsl(220, 10%, 92%)"
    rectFill = "hsl(227, 45%, 25%)"
    triangleFill = "hsl(215, 45%, 88%)"
    triangleSize = 24
    strokeWidth = 2
    
    # State
    showing = false
    panelIsVertical = true
    buttons = []
    nextButtonOffsetY = 0
    activeButtonCancelCb = null
    labelY = 0
    labelHeight = 0
    height = 0
    
    
    # Init label size values
    if props.name?
      labelY = GUI.labelPad + (props.fontSize or 16) * 0.75 # Lato's baseline is about 75% down from the top of the caps
      labelHeight = GUI.labelPad + (props.fontSize or 16) * 1.2 # Lato's descenders are about 120% down from the top of the caps
    else
      labelHeight = 0
    height = labelHeight + GUI.unit
    
    
    # This is the "item" in the main control panel
    itemElm = SVG.create "g", elm, ui: true
    
    if props.name?
      label = SVG.create "text", itemElm,
        textContent: props.name
        x: GUI.colInnerWidth/2
        y: labelY
        fontSize: props.fontSize or 16
        fontWeight: props.fontWeight or "normal"
        fontStyle: props.fontStyle or "normal"
        fill: labelFill
    
    rect = SVG.create "rect", itemElm,
      rx: GUI.borderRadius + 2
      fill: rectFill
      x: 0
      y: labelHeight
      width: GUI.colInnerWidth
      height: GUI.unit
      strokeWidth: strokeWidth
    
    activeLabel = SVG.create "text", itemElm,
      y: labelHeight + 21
      fill: "hsl(92, 46%, 57%)"
    
    labelTriangle = SVG.create "polyline", itemElm,
      points: "6,-6 13,0 6,6"
      transform: "translate(0, #{labelHeight + GUI.unit/2})"
      stroke: triangleFill
      strokeWidth: 4
      strokeLinecap: "round"
      fill: "none"
    
    # This is the panel that pops open when you click the item
    panel = Scope SVG.create "g", elm
    panel.hide 0
    
    panelTriangle = SVG.create "polyline", panel.element,
      points: "#{7 - triangleSize*4/7},#{labelHeight+GUI.unit/2-triangleSize/2} 7,#{labelHeight+GUI.unit/2} #{7 - triangleSize*4/7},#{labelHeight+GUI.unit/2+triangleSize/2}"
      fill: triangleFill
    
    panelInner = SVG.create "g", panel.element
    
    panelRect = SVG.create "rect", panelInner,
      width: GUI.colInnerWidth
      rx: GUI.panelBorderRadius
      fill: triangleFill
    
    buttonContainer = SVG.create "g", panelInner,
      transform: "translate(#{GUI.panelPadding},#{GUI.panelPadding})"
    
    resize = (force = false)->
      return unless showing or force
      
      if panelIsVertical
        panel.x = - GUI.colInnerWidth - 6
        panel.y = labelHeight + GUI.unit/2 - nextButtonOffsetY/2
        SVG.attrs panelTriangle, transform: "translate(4,0)"
      else
        panel.x = 0
        panel.y = - nextButtonOffsetY - triangleSize
        SVG.attrs panelTriangle, transform: "translate(#{GUI.colInnerWidth/2},0) rotate(90)"
      
      SVG.attrs panelInner, transform: "translate(0,0)"
      
      RAF requestReposition, true
        
    requestReposition = ()->
      RAF reposition, true
      
    reposition = ()->
      bounds = panelInner.getBoundingClientRect()
      if bounds.top < GUI.panelMargin
        console.log bounds.top - GUI.panelMargin
        SVG.attrs panelInner, transform: "translate(0,#{-bounds.top + GUI.panelMargin})"
    
    
    setActive = (name, unclick)->
      SVG.attrs activeLabel,
        textContent: name
        x: GUI.colInnerWidth/2 + (if name.length > 14 then 6 else 0)
      activeButtonCancelCb?()
      activeButtonCancelCb = unclick
      if showing
        showing = false
        update()
    
    # Setup the bg stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    tickBG = (_bgc)->
      bgc = _bgc
      SVG.attrs rect, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    tickBG blueBG
    
    update = ()->
      if showing
        panel.show 0
        resize true
      else
        panel.hide 0.2
    
    # Input event handling
    blocked = false
    toNormal   = (e, state)-> Tween bgc, blueBG,  .2, tick:tickBG
    toHover    = (e, state)-> Tween bgc, lightBG,  0, tick:tickBG if not state.touch
    toClicking = (e, state)-> Tween bgc, orangeBG, 0, tick:tickBG
    toClicked  = (e, state)-> Tween bgc, lightBG, .2, tick:tickBG
    Input itemElm,
      moveIn: toHover
      dragIn: (e, state)-> toClicking() if state.clicking
      down: toClicking
      up: toHover
      moveOut: toNormal
      dragOut: toNormal
      upOther: (e, state)->
        if showing
          showing = false
          update()
      click: ()->
        # iOS fires 2 click events in rapid succession, so we debounce it here
        return if blocked
        blocked = true
        setTimeout (()-> blocked = false), 100
        showing = !showing
        update()
    
    Resize (info)->
      panelIsVertical = info.panel.vertical
      resize()
    
    return scope =
      height: height
      
      button: (props)->
        props.setActive = setActive
        buttonElm = SVG.create "g", buttonContainer
        buttonScope = Scope buttonElm, PopoverButton, props
        buttons.push buttonScope
        buttonScope.y = nextButtonOffsetY
        nextButtonOffsetY += GUI.unit + GUI.itemMargin
        SVG.attrs panelRect, height: nextButtonOffsetY + GUI.panelPadding*2 - GUI.itemMargin
        
        return buttonScope
      
      _highlight: (enable)->
        if enable
          SVG.attrs label, fill: "url(#LightHighlightGradient)"
          SVG.attrs rect, fill: "url(#DarkHighlightGradient)"
        else
          SVG.attrs label, fill: labelFill
          SVG.attrs rect, fill: rectFill
        button._highlight enable for button in buttons
