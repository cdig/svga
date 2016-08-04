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
    
    # Button text label
    label = SVG.create "text", elm,
      textContent: props.name
      fill: "hsl(220, 16%, 24%)"
    
    # Pre-compute some size info that will be used later on for layout
    w = Math.max 48, label.getComputedTextLength() + GUI.pad*8
    h = 48
    
    # Setup the bg fill color, and allow it to be easily animated later
    bgFill = (v)-> SVG.attrs bg.element, fill: "hsl(220,16%,#{v*83}%)", stroke: "hsl(220,16%,#{v*24}%)"
    bgFill 1
    
    # Animations for the bg fill color
    depress = ()-> Tween 1, .7, .2, bgFill
    release = ()-> Tween .7, 1, .2, bgFill
    
    # Input event handling
    Input elm,
      click: ()-> handler() for handler in handlers
      down: depress
      up: release
    
    # Our scope just has the 3 mandatory control functions, nothing special.
    return scope =
      attach: (props)-> handlers.push props.click if props.click?
      
      getPreferredSize: ()-> w:w, h:h
      
      resize: ({w:w, h:h})->
        SVG.attrs bg.element, width: w - GUI.pad*2, height: h - GUI.pad*2
        SVG.attrs label, x: w/2, y: h/2 + 6
