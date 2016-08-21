Take ["Config", "ControlPanel", "Nav", "RAF", "Resize"], (Config, ControlPanel, Nav, RAF, Resize)->
  return unless Config.nav
  
  Resize ()->
    # This rect holds the amount of space in the GUI
    rect =
      x: 0
      y: 0
      w: window.innerWidth
      h: window.innerHeight
    
    # These mutate rect, shrinking it based on the space they need
    ControlPanel.claimSpace rect
    
    # Whatever space is left, we give to Nav
    Nav.assignSpace rect
