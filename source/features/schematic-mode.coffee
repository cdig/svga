Take ["SVGA:Features"], (Features)->
  Features["schematicMode"] = (root)->
    return scope =
      
      schematicMode: ()->
        scope.dispatchSchematicMode mainStage.root
      
      animateMode: ()->
        scope.dispatchAnimateMode mainStage.root
      

      dispatchSchematicMode: (instance)->
        instance.schematicMode?()
        scope.setLinesBlack instance
        scope.dispatchSchematicMode child for child in instance.children
      
      dispatchAnimateMode: (instance)->
        instance.animateMode?()
        scope.removeLinesBlack instance
        scope.dispatchAnimateMode child for child in instance.children
      
      
      setLinesBlack: (instance)->
        element = instance.getElement()
        if element.getAttribute("id")?.indexOf("Line") > -1
          element.setAttribute "filter", "url(#allblackMatrix)"
      
      removeLinesBlack: (instance)->
        element = instance.getElement()
        if element.getAttribute("id")?.indexOf("Line") > -1
          element.removeAttribute "filter"
