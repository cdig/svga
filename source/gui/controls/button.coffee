Take ["Control", "GUI", "Input", "Scope", "SVG", "Tween"], (Control, {ControlPanel:GUI}, Input, Scope, SVG, Tween)->
  Control "button", (elm, props)->
    
    # An array to hold all the click functions that have been attached to this button
    handlers = []
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    # Button background element
    bg = Scope SVG.create "rect", elm,
      x: GUI.pad
      y: GUI.pad
      rx: GUI.borderRadius
      strokeWidth: 2
      fill: "hsl(220, 10%, 92%)"
    
    # Button text label
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "hsl(227, 16%, 24%)"
    
    # Pre-compute some size info that will be used later on for layout
    w = Math.max GUI.unit, label.getComputedTextLength() + GUI.pad*8
    h = GUI.unit
    
    # Setup the bg stroke color for tweening
    blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    bgFill = ({r:r,g:g,b:b})-> SVG.attrs bg.element, stroke: "rgb(#{r|0},#{g|0},#{b|0})"
    bgFill blueBG
    
    # Input event handling
    Input elm,
      over: ()-> bgFill lightBG
      down: ()-> bgFill orangeBG
      out: ()-> Tween lightBG, blueBG, .2, tick:bgFill
      click: ()->
        handler() for handler in handlers
        Tween orangeBG, lightBG, .2, tick:bgFill
    
    # Our scope just has the 3 mandatory control functions, nothing special.
    return scope =
      attach: (props)-> handlers.push props.click if props.click?
      
      getPreferredSize: ()-> w:w, h:h
      
      resize: ({w:w, h:h})->
        SVG.attrs bg.element, width: w - GUI.pad*2, height: h - GUI.pad*2
        SVG.attrs label, x: w/2, y: h/2 + 6
        return w:w, h:h
