Take ["PureDom", "HydraulicPressure"], (PureDom, HydraulicPressure)->
  Make "SVGStyle", SVGStyle = (svgElement)->
    scope = 
      visible: (isVisible)->
        if isVisible
          svgElement.style.visibility = "visible"
        else
          svgElement.style.visibility = "hidden"

      pressure: 0

      setPressure: (val)->
        scope.pressure = val
        scope.fill(HydraulicPressure(scope.pressure))


      getPressure: ()->
        return scope.pressure

      getPressureColor: (pressure)->
        return HydraulicPressure(pressure)

      fill: (color)->
        path = svgElement.querySelector("path")
        use = svgElement.querySelector("use")
        if not path? and use?
          useParent = PureDom.querySelectorParent(use, "g")
          parent = PureDom.querySelectorParent(svgElement, "svg")
          defs = parent.querySelector("defs")
          link = defs.querySelector(use.getAttribute("xlink:href"))
          clone = link.cloneNode(true)
          useParent.appendChild(clone)
          useParent.removeChild(use)

        path = svgElement.querySelector("path")
        if path?
          path.setAttributeNS(null, "fill", color)

      linearGradient: (stops, x1=0, y1=0, x2=1, y2=0)->
        useParent = PureDom.querySelectorParent(svgElement, "svg")
        gradientName = "Gradient_" + svgElement.getAttributeNS(null, "id")
        gradient = document.createElementNS("http://www.w3.org/2000/svg", "linearGradient")
        useParent.querySelector("defs").appendChild(gradient)
        gradient.setAttribute("id", gradientName)

        gradient.setAttributeNS(null,"x1", x1)
        gradient.setAttributeNS(null,"y1", y1)
        gradient.setAttributeNS(null,"x2", x2)
        gradient.setAttributeNS(null,"y2", y2)

        for stop in stops
          gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop")
          gradientStop.setAttribute("offset", stop.offset)
          gradientStop.setAttribute("stop-color", stop.color)
          gradient.appendChild(gradientStop)

        fillUrl = "url(##{gradientName})"
        scope.fill(fillUrl)
      
      radialGradient: (stops, cx, cy, radius)->
        useParent = PureDom.querySelectorParent(svgElement, "svg")
        gradientName = "Gradient_" + svgElement.getAttributeNS(null, "id")
        oldGradient = useParent.querySelector("defs").querySelector("##{gradientName}")
        useParent.querySelector("defs").removeChild(oldGradient) if oldGradient
        gradient = document.createElementNS("http://www.w3.org/2000/svg", "radialGradient")
        useParent.querySelector("defs").appendChild(gradient)
        gradient.setAttribute("id", gradientName)

        gradient.setAttributeNS(null,"cx", cx) if cx?
        gradient.setAttributeNS(null,"cy", cy) if cy?
        gradient.setAttributeNS(null,"r", radius) if radius?

        for stop in stops
          gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop")
          gradientStop.setAttribute("offset", stop.offset)
          gradientStop.setAttribute("stop-color", stop.color)
          gradient.appendChild(gradientStop)
        fillUrl = "url(##{gradientName})"
        scope.fill(fillUrl)

      setText: (text)->
        textElement = svgElement.querySelector("text").querySelector("tspan")
        if textElement?
          textElement.textContent=text        

      setProperty: (propertyName, propertyValue)->
        svgElement.style[propertyName] = propertyValue

      getElement: ()->
        return svgElement