Take ["Draggable", "POI", "PointerInput"], (Draggable, POI, PointerInput)->
  Make "SVGPOI", SVGPOI = (control, controlButton, svgActivity, camera)->
    return scope =
      open: false
      pois: {}
      
      setup: ()->
        scope.draggable = new Draggable(control, svgActivity)
        scope.draggable.setup()

        PointerInput.addClick controlButton.getElement(), scope.toggle

        if control.closer?
          PointerInput.addClick control.closer.getElement(), scope.hide
        else
          console.log "Warning: POI panel does not have closer button"
        
        scope.hide()
        for name, poi of control
          if name.indexOf("poi") > -1
            scope.pois[name] = new POI(poi, camera)
            scope.pois[name].setup()
          else if name.indexOf("reset") > -1
            scope.pois[name] = new POI(poi, camera)
            scope.pois[name].setup()


      toggle: ()->
        if scope.open then scope.hide() else scope.show()

      show: ()->
        scope.open = true
        control.style.show(true)

      hide: ()->
        scope.open = false
        control.style.show(false)
