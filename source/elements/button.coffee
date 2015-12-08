do ->
  Make "button", Button = (svgElement)->
    return scope =
      callbacks: []
      setup: ()->
        svgElement.addEventListener "click", scope.clicked
      getElement: ()->
        return svgElement

      setCallback: (callback)->
        scope.callbacks.push callback

      clicked: ()->
        for callback in scope.callbacks
          callback()
