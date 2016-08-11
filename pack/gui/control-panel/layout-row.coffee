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
      
      resize: ({x:x,y:y}, view, vertical)->
        extraSpace = (GUI.width-consumedWidth)/elements.length
        consumedX = 0
        consumedY = 0
        for element in elements
          w = element.size.w + extraSpace
          h = consumedHeight
          actual = element.scope.resize w:w, h:h, x:x, y:y, view, vertical
          element.scope.x = x + consumedX
          element.scope.y = y
          consumedX += actual.w
          consumedY = Math.max consumedY, actual.h
        return w:consumedX, h:consumedY
