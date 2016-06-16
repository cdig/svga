Take ["PointerInput", "Global"], (PointerInput, Global)->
  Make "SVGAnimate", (toggle, svgControlPanel, mainStage)->
    return scope =
      
      setup: ()->
        PointerInput.addClick toggle.animateSelected.getElement(), ()-> scope.setMode false
        PointerInput.addClick toggle.schematicSelected.getElement(), ()-> scope.setMode true
      
      setMode: (animate)->
        if Global.animateMode isnt animate
          Global.animateMode = animate
          toggle.animateSelected.style.show animate
          toggle.schematicSelected.style.show !animate
          if animate then scope.animateMode() else scope.schematicMode()
      
      
      schematicMode: ()->
        scope.disableControlPanelButtons()
        scope.dispatchSchematicMode mainStage.root
      
      animateMode: ()->
        scope.enableControlPanelButtons()
        scope.dispatchAnimateMode(mainStage.root)
      

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
      
      
      disableControlPanelButtons: ()->
        for name in ["arrows", "controls", "mimic"]
          mainStage.root._controlPanel[name]?.disable()
          svgControlPanel[name]?.getElement().setAttribute "filter", "url(#greyscaleMatrix)"
      
      enableControlPanelButtons: ()->
        for name in ["arrows", "controls", "mimic"]
          mainStage.root._controlPanel[name]?.enable()
          svgControlPanel[name]?.getElement().removeAttribute "filter"
