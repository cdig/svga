Take ["SVGArrows", "SVGBackground","SVGBOM", "SVGCamera", "SVGControl","SVGLabels", "SVGMimic", "SVGPOI", "SVGAnimate", "RequestUniqueAnimation"],
(SVGArrows, SVGBackground, SVGBOM, SVGCamera, SVGControl, SVGLabels, SVGMimic, SVGPOI, SVGAnimate, RequestUniqueAnimation)->
  Make "SVGControlPanel", SVGControlpanel = (root)->
    
    controlPanel = root.controlPanel
    
    onResize = ()->
      # This is the natural size of the SVG graphic in units
      svgRect = root.getElement().viewBox.baseVal
      
      # This is the outer size of the SVG graphic in pixels
      outerRect = root.getElement().getBoundingClientRect()
      
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
      root.ctrlPanel.transform.scale = 1/scale if root.ctrlPanel?
      root.mimicPanel.transform.scale = 1/scale if root.mimicPanel?
      root.poiPanel.transform.scale = 1/scale if root.poiPanel?
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
        rootElement = root.getElement()
        rootElement.appendChild(controlPanel.getElement())

        if controlPanel.nav?
          rootElement.appendChild(root.navOverlay.getElement()) #these appends are done to
          #place elements on top layer
          scope.camera = new SVGCamera(rootElement, root.mainStage, root.navOverlay, controlPanel.nav)
          scope.camera.setup?()

        if controlPanel.poi? and root.poiPanel?
          scope.poi = new SVGPOI(root.poiPanel, controlPanel.poi, root, scope.camera)
          scope.poi.setup?()

        if controlPanel.bom?
          scope.bom = new SVGBOM(document, root,controlPanel.bom )
          scope.bom.setup?()

        if controlPanel.background?
          scope.background = new SVGBackground(document, root, controlPanel.background)
          scope.background.setup?()

        if root.ctrlPanel? and controlPanel.controls
          rootElement.appendChild(root.ctrlPanel.getElement())
          scope.controls = new SVGControl(root, root.ctrlPanel, controlPanel.controls)
          scope.controls.setup?()
        
        if root.mimicPanel? and controlPanel.mimic
          rootElement.appendChild(root.mimicPanel.getElement())
          scope.mimic = new SVGControl(root, root.mimicPanel, controlPanel.mimic)
          scope.mimic.setup?()

        if controlPanel.labels?
          scope.labels = new SVGLabels(root, root.mainStage.labelsContainer, controlPanel.labels)
          scope.labels.setup?()

        if controlPanel.arrows?
          scope.arrows = new SVGArrows(root, root.FlowArrows, controlPanel.arrows)
          scope.arrows.setup?()
        
        if controlPanel.toggle and controlPanel.toggle.schematicSelected? and controlPanel.toggle.animateSelected?
          scope.schematicToggle = new SVGAnimate(controlPanel.toggle, controlPanel, root.mainStage)
          scope.schematicToggle.setup?()
        
        window.addEventListener "resize", ()-> RequestUniqueAnimation(onResize, true)
        onResize()
