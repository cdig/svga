do ->
  Take ["SVGArrows", "SVGBackground","SVGBOM", "SVGCamera", "SVGControl","SVGLabels", "SVGPOI"], (SVGArrows, SVGBackground, SVGBOM, SVGCamera, SVGControl, SVGLabels, SVGPOI)->
    Make "SVGControlPanel", SVGControlpanel = ()->
      return scope =
        camera: null
        background: null
        bom: null
        poi: null
        control: null
        labels: null

        setup: (activity, controlPanel)->
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
          if controlPanel.labels?
            scope.labels = new SVGLabels(activity, activity.mainStage.labelsContainer, controlPanel.labels)
            scope.labels.setup()
          if controlPanel.arrows?

            scope.arrows = new SVGArrows(activity, activity.FlowArrows, controlPanel.arrows)
            scope.arrows.setup()

          #compute proper position


