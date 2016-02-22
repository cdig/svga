do ->
  Take ["SVGBackground","SVGBOM", "SVGCamera", "SVGControl", "SVGPOI"], (SVGBackground, SVGBOM, SVGCamera, SVGControl, SVGPOI)->
    Make "SVGControlPanel", SVGControlpanel = ()->
      return scope =
        camera: null
        background: null
        bom: null
        poi: null
        control: null

        setup: (activity, controlPanel)->
          activityElement = activity.getElement()
          scope.camera = new SVGCamera(activityElement, activity.mainStage, activity.navOverlay, controlPanel.nav)
          scope.camera.setup()

          scope.bom = new SVGBOM(document, activity,controlPanel.bom )
          scope.bom.setup()
          scope.background = new SVGBackground(document, activity, controlPanel.background)
          scope.background.setup()
          scope.control = new SVGControl(activity, activity.ctrlPanel, controlPanel.controls )
          scope.control.setup()
          scope.poi = new SVGPOI(activity.poiPanel, controlPanel.poi, activity, scope.camera)
          scope.poi.setup()

