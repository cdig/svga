Take ["PointerInput", "Resize", "SVG", "TRS"], (PointerInput, Resize, SVG, TRS)->
  topbarHeight = 48
  
  elements = []
  
  controlPanel = TRS SVG.create "g", SVG.root, class: "ControlPanel"
  bg = SVG.create "rect", controlPanel, class: "BG"
  
  
  Resize resize = ()->
    panelWidth = Math.ceil 5 * Math.sqrt window.innerWidth
    SVG.attr bg, "width", panelWidth
    SVG.attr bg, "height", window.innerHeight - topbarHeight
    TRS.move controlPanel, window.innerWidth - panelWidth, topbarHeight
    Make "ControlPanelReady" unless Take "ControlPanelReady"
  
  
  Make "ControlPanel", ControlPanel =
    
    # This is sugared as SVGA.control
    addControl: (props)->

      if props.type?
        
        # Panel components are defined using Make()
        Take "Controls:" + props.type, (fn)->
          control = fn props
      
      else
        console.log props
        throw "^ You must include a 'type' property when creating an SVGA.control instance"
