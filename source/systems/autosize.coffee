Take ["Mode", "ParentElement", "Resize", "SVG"], (Mode, ParentElement, Resize, SVG)->
  return unless Mode.autosize
  
  width = SVG.attr SVG.svg, "width"
  height = SVG.attr SVG.svg, "height"
  
  newWidth = null
  
  resize = ()->
    if ParentElement.offsetWidth isnt newWidth
      newWidth = ParentElement.offsetWidth
      newHeight = height * newWidth / width |0
      ParentElement.style.height = newHeight + "px"
  
  Resize resize
