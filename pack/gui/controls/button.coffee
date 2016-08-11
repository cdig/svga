Take ["Control", "GUI", "Input", "SVG", "Tween"], (Control, {ControlPanel:GUI}, Input, SVG, Tween)->
  Control "button", (elm, props)->
    
    # An array to hold all the click functions that have been attached to this button
    handlers = []
    
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    
    # Button background element
    bg = SVG.create "rect", elm,
      x: GUI.pad
      y: GUI.pad
      rx: GUI.borderRadius
      strokeWidth: 2
      fill: "hsl(220, 10%, 92%)"
    
    # Button text label
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "hsl(227, 16%, 24%)"
    
    
    # Pre-compute some size info that will be used later for layout
    w = Math.max GUI.unit, label.getComputedTextLength() + GUI.pad*8
    h = GUI.unit
    
    
    # Setup the bg stroke color for tweening
    bgc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    bgFill = (_bgc)->
      bgc = _bgc
      unless scope?.highlightActive
        SVG.attrs bg, stroke: "rgb(#{bgc.r|0},#{bgc.g|0},#{bgc.b|0})"
    bgFill blueBG
    
    
    # Input event handling
    toNormal   = (e, state)-> Tween bgc, blueBG,  .2, tick:bgFill
    toHover    = (e, state)-> Tween bgc, lightBG,  0, tick:bgFill if not state.touch
    toClicking = (e, state)-> Tween bgc, orangeBG, 0, tick:bgFill
    toClicked  = (e, state)-> Tween bgc, lightBG, .2, tick:bgFill
    Input elm,
      moveIn: toHover
      dragIn: (e, state)-> toClicking() if state.clicking
      down: toClicking
      up: toHover
      moveOut: toNormal
      dragOut: toNormal
      click: ()->
        toClicked()
        handler() for handler in handlers
    
    
    # Our scope just has the 3 mandatory control functions, nothing special.
    return scope =
      attach: (props)-> handlers.push props.click if props.click?
      getPreferredSize: ()-> w:w, h:h
      resize: ({w:w, h:h})->
        SVG.attrs bg, width: w - GUI.pad*2, height: h - GUI.pad*2
        SVG.attrs label, x: w/2, y: h/2 + 6
        return w:w, h:h
