Take ["SVGArrows", "SVGBackground","SVGBOM", "SVGCamera", "SVGControl","SVGLabels", "SVGMimic", "SVGPOI", "SVGSchematic"], (SVGArrows, SVGBackground, SVGBOM, SVGCamera, SVGControl, SVGLabels, SVGMimic, SVGPOI, SVGSchematic)->
  Make "SVGControlPanel", SVGControlpanel = (activity, controlPanel)->
    return scope =
      camera: null
      background: null
      bom: null
      poi: null
      control: null
      labels: null
      panelHeight: 50 #this is the default panel height

      setup: ()->
        activityElement = activity.getElement()
        if controlPanel.nav?
          scope.camera = new SVGCamera(activityElement, activity.mainStage, activity.navOverlay, controlPanel.nav)
          scope.camera.setup()
          if controlPanel.poi? and activity.poiPanel?
            scope.poi = new SVGPOI(activity.poiPanel, controlPanel.poi, activity, scope.camera)
            scope.poi.setup()
        if controlPanel.bom?
          scope.bom = new SVGBOM(document, activity,controlPanel.bom )
          scope.bom.setup()
        if controlPanel.background?
          scope.background = new SVGBackground(document, activity, controlPanel.background)
          scope.background.setup()
        if activity.ctrlPanel? and controlPanel.controls
          scope.control = new SVGControl(activity, activity.ctrlPanel, controlPanel.controls )
          scope.control.setup()
        if activity.mimicPanel? and controlPanel.mimic
          scope.control = new SVGControl(activity, activity.mimicPanel, controlPanel.mimic )
          scope.control.setup()
        if controlPanel.labels?
          scope.labels = new SVGLabels(activity, activity.mainStage.labelsContainer, controlPanel.labels)
          scope.labels.setup()
        if controlPanel.arrows?
          scope.arrows = new SVGArrows(activity, activity.FlowArrows, controlPanel.arrows)
          scope.arrows.setup()

        if controlPanel.toggle and controlPanel.toggle.schematicSelected? and controlPanel.toggle.animateSelected?
          scope.schematicToggle = new SVGSchematic(controlPanel.toggle, controlPanel, activity.mainStage)
          scope.schematicToggle.setup()
        scope.handleScaling()

      handleScaling: ()->
        onResize = ()->
          controlPanelBox = controlPanel.getElement().getBoundingClientRect()
          scaleAmount = scope.panelHeight / (controlPanelBox.height / controlPanel.transform.scale)
          controlPanel.transform.scale = scaleAmount
          activity.ctrlPanel.transform.scale = scaleAmount if activity.ctrlPanel?
          activity.mimicPanel.transform.scale = scaleAmount if activity.mimicPanel?
          activity.poiPanel.transform.scale = scaleAmount if activity.poiPanel?
          controlPanelBox = controlPanel.getElement().getBoundingClientRect()
          activityBox = activity.getElement().getBoundingClientRect()

          controlPanel.transform.y += activityBox.height - controlPanelBox.top - 50

        window.addEventListener "resize", ()->
          onResize()
          onResize()
        onResize()
        onResize()


