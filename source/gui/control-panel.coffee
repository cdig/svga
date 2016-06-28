Take ["PointerInput", "Resize", "SVG", "TRS"], (PointerInput, Resize, SVG, TRS)->
  topbarHeight = 48
  
  elements = []
  
  controlPanel = TRS.create SVG.root, class: "ControlPanel"
  bg = SVG.create "rect", controlPanel, class: "BG"
  
  
  Resize resize = ()->
    panelWidth = Math.ceil 5 * Math.sqrt window.innerWidth
    SVG.attr bg, "width", panelWidth
    SVG.attr bg, "height", window.innerHeight - topbarHeight
    
    TRS.move controlPanel, window.innerWidth - panelWidth, topbarHeight
    
  
  construct = (name, fn)->
    i = elements.length
  
  
  Make "ControlPanel", ControlPanel =
    
    # This will be called by many symbols
    addControl: (name, cb)->

      # Panel elements are defined using Make()
      Take name, (fn)->
        construct name, fn
