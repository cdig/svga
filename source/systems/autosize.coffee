Take ["Mode", "ParentObject", "SVG"], (Mode, ParentObject, SVG)->
  return unless Mode.autosize
  
  width = SVG.attr SVG.root, "width"
  height = SVG.attr SVG.root, "height"
  
  newWidth = null
  
  resize = ()->
    if ParentObject.offsetWidth isnt newWidth
      newWidth = ParentObject.offsetWidth
      newHeight = height * newWidth / width |0
      ParentObject.style.height = newHeight + "px"
  
  resize()
  
  # Do another resize once everything is done loading, since our layout might have shifted
  Take "load", resize
  
  window.top.addEventListener "resize", resize
