Take ["Mode", "ParentElement", "Resize", "SVG"], (Mode, ParentElement, Resize, SVG)->
  return unless Mode.autosize
  
  width = SVG.attr SVG.svg, "width"
  height = SVG.attr SVG.svg, "height"
  
  newWidth = null
  
  resize = ()->
    if ParentElement.clientWidth isnt newWidth
      newWidth = ParentElement.clientWidth
      newHeight = height * newWidth / width |0
      ParentElement.style.height = newHeight + "px"
  
  Resize resize
