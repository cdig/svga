do ->
  Take "PureDom", (PureDom)->
    Make "SVGBackground", SVGBackground = (parentElement, activity, control)->
      return scope =
        currentBackground: 0
        activity: null
        setup: ()->
          scope.cycleBackground(activity)
          control.getElement().addEventListener "click", ()->
            scope.cycleBackground(activity)

        cycleBackground: (activity)->
          scope.currentBackground++
          scope.currentBackground %= 3
          svgElement = activity.getElement()#PureDom.querySelectorParent(activity.getElement(), "svg-activity")
          switch scope.currentBackground
            when 0
              svgElement.style["background-color"] = "#666666"
            when 1
              svgElement.style["background-color"] = "#bbbbbb"
            when 2
              svgElement.style["background-color"] = "#ffffff"