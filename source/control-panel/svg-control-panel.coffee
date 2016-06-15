Take ["SVGArrows", "SVGBackground","SVGBOM", "SVGCamera", "SVGControl","SVGLabels", "SVGMimic", "SVGPOI", "SVGSchematic", "RequestUniqueAnimation"],
(SVGArrows, SVGBackground, SVGBOM, SVGCamera, SVGControl, SVGLabels, SVGMimic, SVGPOI, SVGSchematic, RequestUniqueAnimation)->
  Make "SVGControlPanel", SVGControlpanel = (activity, controlPanel)->
    onResize = ()->
      # This is the natural size of the SVG graphic in units
      svgRect = activity.getElement().viewBox.baseVal
      
      # This is the outer size of the SVG graphic in pixels
      outerRect = activity.getElement().getBoundingClientRect()
      
      # Figure out the scaling factor applied to the SVG
      wScale = outerRect.width / svgRect.width
      hScale = outerRect.height / svgRect.height
      scale = Math.min wScale, hScale
      
      # This is the natural size of the SVG graphic in pixels
      innerRect =
        width: svgRect.width * scale
        height: svgRect.height * scale
      
      # This is the position of the innerRect within the outerRect in pixels
      innerRect.left = (outerRect.width - innerRect.width)/2
      innerRect.top = (outerRect.height - innerRect.height)/2
      
      # This works fine, assuming the controlPanel is placed at the bottom of the SVG viewBox and is unscaled
      # This is disabled because we're doing the LEGACY stuff below
      # controlPanel.transform.y = innerRect.top / scale
      
      # LEGACY:
      controlPanel.transform.scale = 1/scale
      activity.ctrlPanel.transform.scale = 1/scale if activity.ctrlPanel?
      activity.mimicPanel.transform.scale = 1/scale if activity.mimicPanel?
      activity.poiPanel.transform.scale = 1/scale if activity.poiPanel?
      controlPanel.transform.y = innerRect.top + (scope.panelHeight*scale - scope.panelHeight)
    
    return scope =
      camera: null
      background: null
      bom: null
      poi: null
      control: null
      labels: null
      panelHeight: 50 # This is the default panel height

      setup: ()->
        activityElement = activity.getElement()
        activityElement.appendChild(controlPanel.getElement())

        if controlPanel.nav?
          activityElement.appendChild(activity.navOverlay.getElement()) #these appends are done to
          #place elements on top layer
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
          activityElement.appendChild(activity.ctrlPanel.getElement())
          scope.controls = new SVGControl(activity, activity.ctrlPanel, controlPanel.controls)
          scope.controls.setup()
        
        if activity.mimicPanel? and controlPanel.mimic
          activityElement.appendChild(activity.mimicPanel.getElement())
          scope.mimic = new SVGControl(activity, activity.mimicPanel, controlPanel.mimic)
          scope.mimic.setup()

        if controlPanel.labels?
          scope.labels = new SVGLabels(activity, activity.mainStage.labelsContainer, controlPanel.labels)
          scope.labels.setup()

        if controlPanel.arrows?
          scope.arrows = new SVGArrows(activity, activity.FlowArrows, controlPanel.arrows)
          scope.arrows.setup()
        
        if controlPanel.toggle and controlPanel.toggle.schematicSelected? and controlPanel.toggle.animateSelected?
          scope.schematicToggle = new SVGSchematic(controlPanel.toggle, controlPanel, activity.mainStage)
          scope.schematicToggle.setup()
        
        window.addEventListener "resize", ()-> RequestUniqueAnimation(onResize, true)
        onResize()
