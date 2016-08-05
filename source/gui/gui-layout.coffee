Take ["ControlPanel", "Nav", "RAF", "Resize", "TopBar"], (ControlPanel, Nav, RAF, Resize, TopBar)->
  Resize ()->
    RAF ()->
      # This rect holds the amount of space in the GUI
      rect =
        x: 0
        y: 0
        w: window.innerWidth
        h: window.innerHeight
      
      # These mutate rect, shrinking it based on the space they need
      TopBar.claimSpace rect
      ControlPanel.claimSpace rect
      
      # Whatever space is left, we give to Nav
      Nav.assignSpace rect
