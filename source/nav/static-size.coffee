Take ["ControlPanel", "Resize", "SVG", "HUD"], (ControlPanel, Resize, SVG, HUD)->
  
  Make "StaticSize", ()->
    
    # Our SVGs don't have a viewbox, which means they render at 1:1 scale with surrounding content,
    # and are cropped when resized. We use their specified width and height as the desired bounding rect.
    width = SVG.attr SVG.svg, "width"
    height = SVG.attr SVG.svg, "height"
    throw new Error "This SVG is missing the required 'width' and 'height' attributes. Please re-export it from Flash." unless width? and height?
    
    # TODO: We need to find a way to delay this until after the ControlPanel is resized
    # Otherwise, we get inconsistency when near the vertical/horizontal crossover point
    Resize ()->
      
      # We need to use SVG.svg.gBCR(), because window.innerWidth/Height are sometimes 0 or wrong.
      windowSize = SVG.svg.getBoundingClientRect()
      
      panelInfo = ControlPanel.getAutosizePanelInfo()
      
      # Figure out whether to leave room for the panel, or just scale to fit the full window.
      # (Note: Only one of panelInfo.w and panelInfo.h will be non-zero, based on whether we're in vertical or horizontal mode.)
      # (Eg: If the panel is in the bottom right corner, then we'll make room for it on the side when vertical, bottom when horizontal.)
      # Note: We look for values greater than 0.9, because there are a lot of modules that used 0.9 (instead of 1) as a way to get rounded corners in v3.
      panelClaimedW = if Math.abs(panelInfo.signedX) >= 0.9 then panelInfo.w else 0
      panelClaimedH = if Math.abs(panelInfo.signedY) >= 0.9 then panelInfo.h else 0
      
      # Figure out how much space is available for our main graphic
      availableW = windowSize.width - panelInfo.w
      availableH = windowSize.height - panelInfo.h
      
      # How much should we scale the graphic so it fits inside our available space?
      wFrac = availableW / width
      hFrac = availableH / height
      scale = Math.min wFrac, hFrac
      
      # If the panel is on the top or left, shift the graphic over to the bottom or right
      xSign = panelInfo.signedX / Math.abs panelInfo.signedX
      ySign = panelInfo.signedY / Math.abs panelInfo.signedY
      xShift = if xSign < 0 then panelInfo.w else 0
      yShift = if ySign < 0 then panelInfo.h else 0
      
      # Center the scaled graphic within the available space
      x = xShift + availableW/2 - (width * scale / 2)
      y = yShift + availableH/2 - (height * scale / 2)
      
      transform = "translate(#{x}, #{y}) scale(#{scale})"
      SVG.attr SVG.root, "transform", transform
