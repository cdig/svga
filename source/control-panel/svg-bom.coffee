do ->
  Make "SVGBOM", SVGBOM = (parentElement)->
    return scope = 
      callbacks: []
      setup: (activity, control)->
        control.getElement().addEventListener "click", ()->
          for callback in scope.callbacks
            callback()

      setCallback: (callback)->
        scope.callbacks.push callback

