Take ["ControlPanel", "Mode", "Nav", "Resize", "SVG", "SceneReady"], (ControlPanel, Mode, Nav, Resize, SVG)->
  Resize ()->
    # This rect holds the amount of space in the GUI
    cbr = SVG.svg.getBoundingClientRect()
    rect =
      x: 0
      y: 0
      w: cbr.width
      h: cbr.height
    
    # claimSpace mutates the rect, shrinking it based on the space needed
    ControlPanel.claimSpace rect
    
    # Whatever space is left, we give to Nav
    Nav.assignSpace rect if Mode.nav
