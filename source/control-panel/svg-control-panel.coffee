do ->
  Take ["SVGBackground","SVGBOM", "SVGCamera", "SVGControl"], (SVGBackground, SVGBOM, SVGCamera, SVGControl)->
    Make "SVGControlPanel", SVGControlpanel = ()->
      return scope = 
        camera: null
        background: null
        bom: null
        control: null

        setup: (activity, controlPanel)->

          activityElement = activity.getElement()

          scope.camera = new SVGCamera(activityElement)
          scope.camera.setup(activity.mainStage, activity.navOverlay, controlPanel.nav)
          scope.bom = new SVGBOM(document)
          scope.bom.setup(activity,controlPanel.labels )
          scope.background = new SVGBackground(document)
          scope.background.setup(activity, controlPanel.background)
          scope.control = new SVGControl(activity.ctrlPanel, controlPanel.controls)
          scope.control.setup(activity)

  