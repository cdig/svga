Take ["Pressure", "Registry", "ScopeCheck", "SVG"], (Pressure, Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "stroke", "fill", "pressure", "linearGradient", "radialGradient"
    
    element = scope.element
    strokePath = fillPath = element.querySelector "path"
    isLine = element.getAttribute("id")?.indexOf("Line") > -1
        
    
    stroke = null
    Object.defineProperty scope, 'stroke',
      get: ()-> stroke
      set: (val)->
        if stroke isnt val
          SVG.attr element, "stroke", stroke = val
          if strokePath?
            SVG.attr strokePath, "stroke", null
            strokePath = null
    
    
    fill = null
    Object.defineProperty scope, 'fill',
      get: ()-> fill
      set: (val)->
        if fill isnt val
          SVG.attr element, "fill", fill = val
          if fillPath?
            SVG.attr fillPath, "fill", null
            fillPath = null
    
    
    pressure = null
    Object.defineProperty scope, 'pressure',
      get: ()-> pressure
      set: (val)->
        if pressure isnt val
          pressure = val
          if isLine and not scope.root.BROKEN_LINES
            scope.stroke = Pressure scope.pressure
          else
            scope.fill = Pressure scope.pressure
    
    
    scope.linearGradient = (stops, x1=0, y1=0, x2=1, y2=0)->
      # useParent = PureDom.querySelectorParent(element, "svg")
      # gradientName = "Gradient_" + element.getAttributeNS(null, "id")
      # gradient = useParent.querySelector("defs").querySelector("##{gradientName}")
      # if not gradient?
      #   gradient = document.createElementNS("http://www.w3.org/2000/svg", "linearGradient")
      #   useParent.querySelector("defs").appendChild(gradient)
      # gradient.setAttribute("id", gradientName)
      # gradient.setAttributeNS(null,"x1", x1)
      # gradient.setAttributeNS(null,"y1", y1)
      # gradient.setAttributeNS(null,"x2", x2)
      # gradient.setAttributeNS(null,"y2", y2)
      # while gradient.hasChildNodes()
      #   gradient.removeChild(gradient.firstChild)
      # for stop in stops
      #   gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop")
      #   gradientStop.setAttribute("offset", stop.offset)
      #   gradientStop.setAttribute("stop-color", stop.color)
      #   gradient.appendChild(gradientStop)
      # fillUrl = "url(##{gradientName})"
      # scope.fill(fillUrl)
    
    
    scope.radialGradient = (stops, cx, cy, radius)->
      # useParent = PureDom.querySelectorParent(element, "svg")
      # gradientName = "Gradient_" + element.getAttributeNS(null, "id")
      # gradient = useParent.querySelector("defs").querySelector("##{gradientName}")
      # if not gradient?
      #   gradient = document.createElementNS("http://www.w3.org/2000/svg", "radialGradient")
      #   useParent.querySelector("defs").appendChild(gradient)
      # gradient.setAttribute("id", gradientName)
      # gradient.setAttributeNS(null,"cx", cx) if cx?
      # gradient.setAttributeNS(null,"cy", cy) if cy?
      # gradient.setAttributeNS(null,"r", radius) if radius?
      # while gradient.hasChildNodes()
      #   gradient.removeChild(gradient.firstChild)
      # for stop in stops
      #   gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop")
      #   gradientStop.setAttribute("offset", stop.offset)
      #   gradientStop.setAttribute("stop-color", stop.color)
      #   gradient.appendChild(gradientStop)
      # fillUrl = "url(##{gradientName})"
      # scope.fill(fillUrl)
