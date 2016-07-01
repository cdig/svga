Take ["PureDom", "HydraulicPressure", "Global"], (PureDom, HydraulicPressure, Global)->
  Make "Style", Style = (scope)->
    element = scope.element
    styleCache = {}
    isLine = element.getAttribute("id")?.indexOf("Line") > -1
    
    # Check that we aren't about to clobber anything
    for prop in ["pressure", "visible", "alpha", "stroke", "fill", "linearGradient", "radialGradient", "text", "style"]
      if scope[prop]?
        console.log "ERROR ############################################"
        console.log "scope:"
        console.log scope
        console.log "element:"
        console.log element
        throw "^ Transform will clobber scope.#{prop} on this element. Please find a different name for your child/property \"#{prop}\"."
    
    
    pressure = 0
    Object.defineProperty scope, 'pressure',
      get: ()-> pressure
      set: (val)->
        if pressure isnt val
          pressure = val
          if api.isLine and not Global.legacyHydraulicLines
            api.stroke HydraulicPressure api.pressure, alpha
          else
            api.fill HydraulicPressure api.pressure, alpha

    
    
    scope.style = (key, val)->
      unless styleCache[key] is val
        styleCache[key] = val
        element.style[key] = val

    
    scope.visible = (isVisible)->
      if isVisible
        element.style.opacity = 1.0
      else
        element.style.opacity = 0.0
    
    scope.show = (showElement)->
      if showElement
        element.style.visibility = "visible"
      else
        element.style.visibility = "hidden"
    
    scope.getPressure = ()->
      return api.pressure

    scope.getPressureColor = (pressure)->
      return HydraulicPressure(pressure)
    
    scope.stroke = (color)->
      path = element.querySelector("path")
      use = element.querySelector("use")
      if not path? and use?
        useParent = PureDom.querySelectorParent(use, "g")
        parent = PureDom.querySelectorParent(element, "svg")
        defs = parent.querySelector("defs")
        link = defs.querySelector(use.getAttribute("xlink:href"))
        clone = link.cloneNode(true)
        useParent.appendChild(clone)
        useParent.removeChild(use)
      path = element.querySelector("path")
      if path?
        path.setAttributeNS(null, "stroke", color)

    scope.fill = (color)->
      path = element.querySelector("path")
      use = element.querySelector("use")
      if not path? and use?
        useParent = PureDom.querySelectorParent(use, "g")
        parent = PureDom.querySelectorParent(element, "svg")
        defs = parent.querySelector("defs")
        link = defs.querySelector(use.getAttribute("xlink:href"))
        clone = link.cloneNode(true)
        useParent.appendChild(clone)
        useParent.removeChild(use)
      path = element.querySelector("path")
      if path?
        path.setAttributeNS(null, "fill", color)

    scope.linearGradient = (stops, x1=0, y1=0, x2=1, y2=0)->
      useParent = PureDom.querySelectorParent(element, "svg")
      gradientName = "Gradient_" + element.getAttributeNS(null, "id")
      gradient = useParent.querySelector("defs").querySelector("##{gradientName}")
      if not gradient?
        gradient = document.createElementNS("http://www.w3.org/2000/svg", "linearGradient")
        useParent.querySelector("defs").appendChild(gradient)
      gradient.setAttribute("id", gradientName)
      gradient.setAttributeNS(null,"x1", x1)
      gradient.setAttributeNS(null,"y1", y1)
      gradient.setAttributeNS(null,"x2", x2)
      gradient.setAttributeNS(null,"y2", y2)
      while gradient.hasChildNodes()
        gradient.removeChild(gradient.firstChild)
      for stop in stops
        gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop")
        gradientStop.setAttribute("offset", stop.offset)
        gradientStop.setAttribute("stop-color", stop.color)
        gradient.appendChild(gradientStop)
      fillUrl = "url(##{gradientName})"
      api.fill(fillUrl)

    scope.radialGradient = (stops, cx, cy, radius)->
      useParent = PureDom.querySelectorParent(element, "svg")
      gradientName = "Gradient_" + element.getAttributeNS(null, "id")
      gradient = useParent.querySelector("defs").querySelector("##{gradientName}")
      if not gradient?
        gradient = document.createElementNS("http://www.w3.org/2000/svg", "radialGradient")
        useParent.querySelector("defs").appendChild(gradient)
      gradient.setAttribute("id", gradientName)
      gradient.setAttributeNS(null,"cx", cx) if cx?
      gradient.setAttributeNS(null,"cy", cy) if cy?
      gradient.setAttributeNS(null,"r", radius) if radius?
      while gradient.hasChildNodes()
        gradient.removeChild(gradient.firstChild)
      for stop in stops
        gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop")
        gradientStop.setAttribute("offset", stop.offset)
        gradientStop.setAttribute("stop-color", stop.color)
        gradient.appendChild(gradientStop)
      fillUrl = "url(##{gradientName})"
      api.fill(fillUrl)

    scope.setText = (text)->
      textElement = element.querySelector("text").querySelector("tspan")
      if textElement?
        textElement.textContent=text
    
    scope.getElement = ()->
      throw "scope.style.getElement() has been removed. Please use scope.element instead."
