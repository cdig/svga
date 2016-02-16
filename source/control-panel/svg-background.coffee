do ->
  Take "PureDom", (PureDom)->
    Make "SVGBackground", SVGBackground = (parentElement)->
      return scope =
        currentBackground: 0
        activity: null
        setup: (activity, control)->
          control.getElement().addEventListener "click", ()->
            console.log "cycle"
            scope.cycleBackground(activity)

        cycleBackground: (activity)->
          scope.currentBackground++
          scope.currentBackground %= 3
          console.log activity.getElement()
          svgElement = PureDom.querySelectorParent(activity.getElement(), "svg-activity")
          console.log svgElement
          switch scope.currentBackground
            when 0
              svgElement.style["background-color"] = "#ffffff"
              # svgElement.classList.add("red")
              #activity.mainStage.style.fill("#ffffff")
              console.log "number1"
              console.log svgElement
            when 1
              svgElement.style["background-color"] = "#666666"
              #activity.mainStage.style.fill("#666666")
              # svgElement.classList.add("green")
              console.log "number2"
              console.log svgElement
            when 2
              svgElement.style["background-color"] = "#bbbbbb"
              #activity.mainStage.style.fill("#bbbbbb")
              # svgElement.classList.add("blue")
              console.log "number 3"
              console.log svgElement
          svgElement.style.webkitTransform = 'scale(1)';

          height = svgElement.getAttribute("height")
          svgElement.setAttribute("height", "701px")