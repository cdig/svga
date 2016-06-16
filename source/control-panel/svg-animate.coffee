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
      
      
