# Take "PointerInput", (PointerInput)->
#   Make "POI", POI = (control, camera)->
#     scope =
#       scale: 1
#       x: 0
#       y: 0
#       setup: ()->
#         control.getElement().addEventListener "mouseenter", ()->
#           control.style.fill "white"
#         control.getElement().addEventListener "mouseleave", ()->
#           control.style.fill ""
#         PointerInput.addClick control.getElement(), scope.transform
#
#       setTransformation: (x, y, scale)->
#         scope.x = x
#         scope.y = y
#         scope.scale = scale
#
#       transform: ()->
#         camera.zoomToPosition(scope.scale, scope.x, scope.y)
