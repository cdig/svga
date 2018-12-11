Take ["GUI", "Input", "Registry", "SVG", "Tween"], ({ControlPanel:GUI}, Input, Registry, SVG, Tween)->
  Registry.set "Control", "pushButton", (elm, props)->

    # Arrays to hold all the functions that have been attached to this control
    onHandlers = []
    offHandlers = []

    strokeWidth = 2
    radius = GUI.unit * 0.6
    height = Math.max radius * 2, (props.fontSize or 16)

    bgFill = "hsl(220, 10%, 92%)"
    labelFill = props.fontColor or "hsl(220, 10%, 92%)"

    # Enable pointer cursor, other UI features
    SVG.attrs elm, ui: true

    hit = SVG.create "rect", elm,
      width: GUI.colInnerWidth
      height: height
      fill: "transparent"

    button = SVG.create "circle", elm,
      cx: radius
      cy: radius
      r: radius - strokeWidth/2
      strokeWidth: strokeWidth
      fill: bgFill

    label = SVG.create "text", elm,
      textContent: props.name
      x: radius*2 + GUI.labelMargin
      y: radius + (props.fontSize or 16) * 0.375
      textAnchor: "start"
      fontSize: props.fontSize or 16
      fontWeight: props.fontWeight or "normal"
      fontStyle: props.fontStyle or "normal"
      fill: labelFill


    # Setup the button stroke color for tweening
    bsc = blueBG = r:34, g:46, b:89
    lightBG = r:133, g:163, b:224
    orangeBG = r:255, g:196, b:46
    tickBG = (_bsc)->
      bsc = _bsc
      SVG.attrs button, stroke: "rgb(#{bsc.r|0},#{bsc.g|0},#{bsc.b|0})"
    tickBG blueBG


    # Input event handling
    toNormal   = (e, state)-> Tween bsc, blueBG,  .2, tick:tickBG
    toHover    = (e, state)-> Tween bsc, lightBG,  0, tick:tickBG
    toClicking = (e, state)-> Tween bsc, orangeBG, 0, tick:tickBG
    input = Input elm,
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
      input: input

      attach: (props)->
        onHandlers.push props.on if props.on?
        offHandlers.push props.off if props.off?

      _highlight: (enable)->
        if enable
          SVG.attrs button, fill: "url(#LightHighlightGradient)"
          SVG.attrs label, fill: "url(#LightHighlightGradient)"
        else
          SVG.attrs button, fill: bgFill
          SVG.attrs label, fill: labelFill
