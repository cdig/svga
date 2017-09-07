Take ["Mode", "ParentObject", "Resize", "SVG"], (Mode, ParentObject, Resize, SVG)->
  return unless Mode.autosize
  
  width = SVG.attr SVG.root, "width"
  height = SVG.attr SVG.root, "height"
  
  newWidth = null
  
  resize = ()->
    if ParentObject.offsetWidth isnt newWidth
      newWidth = ParentObject.offsetWidth
      newHeight = height * newWidth / width |0
      ParentObject.style.height = newHeight + "px"
  
  Resize resize
