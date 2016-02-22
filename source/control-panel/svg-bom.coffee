do ->
  Make "SVGBOM", SVGBOM = (parentElement, activity, control)->
    return scope =
      callbacks: []
      setup: ()->
        control.getElement().addEventListener "click", ()->
          for callback in scope.callbacks
            callback()

      setCallback: (callback)->
        scope.callbacks.push callback

