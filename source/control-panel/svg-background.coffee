do ->
  Make "SVGBackground", SVGBackground = (parentElement)->
    return scope = 
      setup: (activity, control)->
        control.getElement().addEventListener "click", ()->
          activity.cycleBackground()