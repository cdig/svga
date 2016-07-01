Take ["PureDom", "Pressure", "Global"], (PureDom, Pressure, Global)->
  Make "Style", Style = (scope)->
    element = scope.element
    styleCache = {}
    isLine = element.getAttribute("id")?.indexOf("Line") > -1
    
    textElement = element.querySelector "text"
    textElement = t if (t = textElement?.querySelector "tspan")?
    
    # Check that we aren't about to clobber anything
    for prop in ["pressure", "visible", "alpha", "stroke", "fill", "linearGradient", "radialGradient", "text", "style"]
      if scope[prop]?
        console.log "ERROR ############################################"
        console.log "scope:"
        console.log scope
        console.log "element:"
        console.log element
        throw "^ Transform will clobber scope.#{prop} on this element. Please find a different name for your child/property \"#{prop}\"."


    # We need a better API for changing the element.style property. This sucks.
    scope.style = (key, val)->
      unless styleCache[key] is val
        styleCache[key] = val
        element.style[key] = val
    
    
    pressure = null
    Object.defineProperty scope, 'pressure',
      get: ()-> pressure
      set: (val)->
        if pressure isnt val
          pressure = val
          if isLine and not Global.legacyHydraulicLines
            scope.stroke Pressure scope.pressure, alpha
          else
            # console.log c = Pressure scope.pressure, alpha
            scope.fill Pressure scope.pressure, alpha

    
    text = textElement?.textContent
    Object.defineProperty scope, 'text',
      get: ()-> text
      set: (val)->
        if textElement? and text isnt val
          textElement.textContent = text
    
    
    visible = true
    Object.defineProperty scope, 'visible',
      get: ()-> visible
      set: (val)->
        if visible isnt val
          visible = val
          element.style.opacity = if visible then alpha else 0
    
    
    alpha = 1
    Object.defineProperty scope, 'alpha',
      get: ()-> alpha
      set: (val)->
        if alpha isnt val
          alpha = val
          element.style.opacity = if visible then alpha else 0
    
    
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
      scope.fill(fillUrl)
    
    
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
      scope.fill(fillUrl)
    
    
    # REMOVED #####################################################################################
    
    scope.getPressure = ()->
      throw "scope.getPressure() has been removed. Please use scope.pressure instead."

    scope.setPressure = ()->
      throw "scope.setPressure(x) has been removed. Please use scope.pressure = x instead."

    scope.getPressureColor = (pressure)->
      throw "scope.getPressureColor() has been removed. Please Take and use Pressure() instead."
    
    scope.setText = (text)->
      throw "scope.setText(x) has been removed. Please scope.text = x instead."
