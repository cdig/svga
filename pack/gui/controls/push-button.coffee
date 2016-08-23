Take ["GUI", "Input", "Registry", "SVG", "Tween"], ({ControlPanel:GUI}, Input, Registry, SVG, Tween)->
  buttonWidth = GUI.unit * 1.8
  buttonHeight = GUI.unit * 1.8
    
  Registry.set "Control", "pushButton", (elm, props)->
    
    # Arrays to hold all the functions that have been attached to this control
    onHandlers = []
    offHandlers = []
    
    bgFill = "hsl(220, 10%, 92%)"
    labelFill = "hsl(227, 16%, 24%)"
    
    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true
    
    
    # Button background element
    bg = SVG.create "rect", elm,
      strokeWidth: 2
      fill: bgFill
    
    # Button text label
    label = SVG.create "text", elm,
      textContent: props.name
      fill: labelFill
    
    
    # Pre-compute some size info that will be used later for layout
    buttonWidth = Math.max buttonWidth, label.getComputedTextLength() + GUI.pad*8
    
    
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
      up: ()->
        toHover()
        offHandler() for offHandler in offHandlers
      miss: ()->
        toNormal()
        offHandler() for offHandler in offHandlers
      moveOut: toNormal
        
    
    
    # Our scope just has the 3 mandatory control functions, nothing special.
    return scope =
      attach: (props)->
        onHandlers.push props.on if props.on?
        offHandlers.push props.off if props.off?
      
      getPreferredSize: ()->
        size = Math.max buttonWidth, buttonHeight
        return w:size, h:size
      
      resize: (space)->
        size = Math.max(buttonWidth, buttonHeight)
        extra = x:space.w-size, y:space.h-size
        SVG.attrs bg,
          x: GUI.pad + extra.x/2
          y: GUI.pad + extra.y/2
          width: size - GUI.pad*2
          height: size - GUI.pad*2
          rx: size/2 - GUI.pad
        SVG.attrs label, x: space.w/2, y: space.h/2 + 6
        return w:size, h:size
      
      _highlight: (enable)->
        if enable
          SVG.attrs bg, fill: "url(#LightHighlightGradient)"
          SVG.attrs label, fill: "black"
        else
          SVG.attrs bg, fill: bgFill
          SVG.attrs label, fill: labelFill
