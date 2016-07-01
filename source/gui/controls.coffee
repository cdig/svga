Take ["PointerInput", "Resize", "SVG", "TRS"], (PointerInput, Resize, SVG, TRS)->
  topbarHeight = 48
  instances = []
  
  g = TRS SVG.create "g", SVG.root, class: "Controls"
  bg = SVG.create "rect", g, class: "BG"
  
  
  Resize resize = ()->
    panelWidth = Math.ceil 5 * Math.sqrt window.innerWidth
    SVG.attr bg, "width", panelWidth
    SVG.attr bg, "height", window.innerHeight - topbarHeight
    TRS.move g, window.innerWidth - panelWidth, topbarHeight
    Make "ControlsReady" unless Take "ControlsReady"
  
  
  Make "Control", (props)->
    if not props.type? then console.log(props); throw "^ You must include a 'type' property when creating an SVGA.control instance"
    
    # Panel components are defined using Make()
    Take "Controls:" + props.type, (fn)->
      props.parent ?= g
      instances.push fn props
