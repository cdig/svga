Take ["PointerInput"], (PointerInput)->
  Make "SVGSchematic", SVGSchematic = (toggle, svgControlPanel, mainStage)->
    return scope =
      modeToggle: false
      setup: ()->
        if not toggle.schematicSelected? or not toggle.animateSelected?
          return

        PointerInput.addClick toggle.schematicSelected.getElement(), ()->
          scope.animateMode() if not scope.modeToggle
          scope.modeToggle = true
        PointerInput.addClick toggle.animateSelected.getElement(), ()->
          scope.schematicMode() if scope.modeToggle
          scope.modeToggle = false


      schematicMode: ()->
        toggle.schematicSelected.style.show(true)
        toggle.animateSelected.style.show(false)
        scope.callSchematicMode(mainStage.root)
        for child in mainStage.root.children
          scope.turnLinesBlack(child)
          scope.callSchematicMode(child)

      callSchematicMode: (instance)->
        for child in instance.children
          scope.callSchematicMode(child)

        instance.schematicMode() if instance.schematicMode?

        if svgControlPanel.arrows?
          svgControlPanel.arrows.getElement().setAttribute("filter", "url(#greyscaleMatrix")
        if svgControlPanel.controls?
          svgControlPanel.controls.getElement().setAttribute("filter", "url(#greyscaleMatrix")
        if svgControlPanel.poi?
          svgControlPanel.poi.getElement().setAttribute("filter", "url(#greyscaleMatrix")
        if svgControlPanel.mimic?
          svgControlPanel.mimic.getElement().setAttribute("filter", "url(#greyscaleMatrix")


      turnLinesBlack: (instance)->
        element = instance.getElement()
        id = element.getAttribute("id")
        if id?
          if id.indexOf("Line") > -1
            instance.getElement().setAttribute("filter", "url(#allblackMatrix)")
        if not instance.children?
          return
        for child in instance.children
         scope.turnLinesBlack(child)

      animateMode: ()->
        toggle.schematicSelected.style.show(false)
        toggle.animateSelected.style.show(true)
        scope.callAnimateMode(mainStage.root)
        for child in mainStage.root.children
          scope.turnLinesBack(child)
          scope.callAnimateMode(child)
        if svgControlPanel.arrows?
          svgControlPanel.arrows.getElement().removeAttribute("filter")
        if svgControlPanel.controls?
          svgControlPanel.controls.getElement().removeAttribute("filter")
        if svgControlPanel.poi?
          svgControlPanel.poi.getElement().removeAttribute("filter")
        if svgControlPanel.mimic?
          svgControlPanel.mimic.getElement().removeAttribute("filter")

      callAnimateMode: (instance)->
        for child in instance.children
          scope.callAnimateMode(child)
        instance.animateMode() if instance.animateMode?

      turnLinesBack: (instance)->
        element = instance.getElement()
        id = element.getAttribute("id")
        if id?
          if id.indexOf("Line") > -1
            instance.getElement().removeAttribute("filter")
        if not instance.children?
          return
        for child in instance.children
         scope.turnLinesBlack(child)


