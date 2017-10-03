Take ["ControlPanel", "Mode", "ParentElement", "Resize", "SVG", "SVGReady"], (ControlPanel, Mode, ParentElement, Resize, SVG)->
  
  width = SVG.attr SVG.svg, "width"
  height = SVG.attr SVG.svg, "height"
  
  if Mode.embed
    alert "Implement ResizeEmbed!"
    Make "ResizeEmbed", ResizeEmbed = (consumedHeight)->
        # panelHeight = ControlPanel.getAutosizePanelHeight()
        # cbr = ParentElement.getBoundingClientRect()
        # ParentElement.style.height = (consumedHeight * cbr.width / width |0) + "px"
    Resize ResizeEmbed
  else
    Make "ResizeEmbed", ResizeEmbed = ()-> # Noop
