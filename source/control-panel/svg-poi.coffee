do ->
  Take ["Draggable", "POI", "PointerInput"], (Draggable, POI, PointerInput)->
    Make "SVGPOI", SVGPOI = (control, controlButton)->
      return scope =
        open: false
        pois: {}
        setup: (svgActivity, camera)->
          scope.draggable = new Draggable(control, svgActivity)
          scope.draggable.setup()
          PointerInput.addClick controlButton.getElement(), scope.toggle
          if control.closer?
            PointerInput.addClick control.closer.getElement(), scope.hide
          else
            console.log "Error: POI does not have closer button"
          scope.hide()
          for name, poi of control
            if name.indexOf("poi") > -1
              scope.pois[name] = new POI(poi, camera)
              scope.pois[name].setup()


        toggle: ()->
          scope.open = not scope.open
          if scope.open then scope.show() else scope.hide()

        show: ()->
          scope.open = true
          control.style.show(true)

        hide: ()->
          scope.open = false
          control.style.show(false)