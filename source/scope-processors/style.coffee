Take ["Pressure", "Registry", "ScopeCheck", "SVG"], (Pressure, Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    element = scope.element
    parent = element.parentNode
    placeholder = SVG.create "g"
    strokePath = fillPath = element.querySelector("path")
    isLine = element.getAttribute("id")?.indexOf("Line") > -1
    textElement = element.querySelector "tspan" or element.querySelector "text"
    
    ScopeCheck scope, "pressure", "visible", "alpha", "stroke", "fill", "linearGradient", "radialGradient", "text", "style"
    
    
    applyVisibility = ()->
      if visible and alpha > 0
        if placeholder.parentNode?
          parent.replaceChild element, placeholder
      else
        if element.parentNode?
          parent.replaceChild placeholder, element

    
    # scope.style = (key, val)-> SVG.style element, key, val
    scope.stype = ()-> throw "@style is up for debate. Please show Ivan what you're using it to do."
    
    
    pressure = null
    Object.defineProperty scope, 'pressure',
      get: ()-> pressure
      set: (val)->
        if pressure isnt val
          pressure = val
          if isLine and not scope.root.BROKEN_LINES
            scope.stroke Pressure scope.pressure
          else
            scope.fill Pressure scope.pressure

    
    text = textElement?.textContent
    Object.defineProperty scope, 'text',
      get: ()-> text
      set: (val)->
        if text isnt val
          SVG.attr "textContent", text = val
    
    
    visible = true
    Object.defineProperty scope, 'visible',
      get: ()-> visible
      set: (val)->
        if visible isnt val
          applyVisibility visible = val
    
    
    alpha = 1
    Object.defineProperty scope, 'alpha',
      get: ()-> alpha
      set: (val)->
        if alpha isnt val
          SVG.style element, "opacity", alpha = val
          applyVisibility()
    
    
    scope.stroke = (color)->
      if strokePath?
        SVG.attr strokePath, "stroke", null
        strokePath = null
      SVG.attr element, "stroke", color
    
    
    scope.fill = (color)->
      if fillPath?
        SVG.attr fillPath, "fill", null
        fillPath = null
      SVG.attr element, "fill", color
    
    
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
