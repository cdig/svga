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
          scope.camera = new SVGCamera(activityElement)
          scope.camera.setup(activity.mainStage, activity.navOverlay, controlPanel.nav)

          scope.bom = new SVGBOM(document)
          scope.bom.setup(activity,controlPanel.bom )
          scope.background = new SVGBackground(document)
          scope.background.setup(activity, controlPanel.background)
          scope.control = new SVGControl(activity.ctrlPanel, controlPanel.controls)
          scope.control.setup(activity)
          scope.poi = new SVGPOI(activity.poiPanel, controlPanel.poi)
          scope.poi.setup(activity, scope.camera)

