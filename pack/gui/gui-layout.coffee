Take ["ControlPanel", "Mode", "Nav", "RAF", "Resize", "SceneReady"], (ControlPanel, Mode, Nav, RAF, Resize)->
  Resize ()->
    # This rect holds the amount of space in the GUI
    rect =
      x: 0
      y: 0
      w: window.innerWidth
      h: window.innerHeight
    
    # claimSpace mutates the rect, shrinking it based on the space needed
    ControlPanel.claimSpace rect
    
    # Whatever space is left, we give to Nav
    Nav.assignSpace rect if Mode.nav
