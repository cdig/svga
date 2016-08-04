Take ["GUI"], ({ControlPanel:GUI})->
  Make "LayoutRow", ()->
    consumedWidth = 0
    consumedHeight = 0
    elements = []
    
    return api =
      hasSpace: (size)->
        return consumedWidth + size.w <= GUI.width
      
      add: (scope, size)->
        elements.push
          scope: scope
          size: size
        consumedWidth += size.w
        consumedHeight = Math.max consumedHeight, size.h
      
      getSize: ()->
        w: consumedWidth
        h: consumedHeight
      
      resize: ({x:x,y:y})->
        extraSpace = (GUI.width-consumedWidth)/elements.length
        for element in elements
          w = element.size.w + extraSpace
          h = consumedHeight
          element.scope.resize w:w, h:h
          element.scope.x = x
          element.scope.y = y
          x += w
        return w:GUI.width, h:consumedHeight
