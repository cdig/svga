Take ["ControlPanel", "Mode", "ParentElement", "Resize", "SVG"], (ControlPanel, Mode, ParentElement, Resize, SVG)->
  return unless Mode.autosize
  
  width = SVG.attr SVG.svg, "width"
  height = SVG.attr SVG.svg, "height"
  
  Resize ()->
    panelHeight = ControlPanel.getAutosizePanelHeight()
    cbr = ParentElement.getBoundingClientRect()
    ParentElement.style.height = (panelHeight + height * cbr.width / width |0) + "px"
