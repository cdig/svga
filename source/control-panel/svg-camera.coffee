# Take ["Ease", "PointerInput", "RequestUniqueAnimation"],
#   (Ease, PointerInput, RequestUniqueAnimation)->
#     setupElementWithFunction = (svgElement, element, behaviourCode, addBehaviour, releaseBehaviour)->
#       behaviourId = 0
#
#       onUp = (e)->
#         releaseBehaviour()
#         clearInterval behaviourId
#         PointerInput.removeUp element, onUp
#         PointerInput.removeUp svgElement, onUp
#
#       PointerInput.addDown element, (e)->
#         behaviourId = setInterval addBehaviour, 16
#         PointerInput.addUp element, onUp
#         PointerInput.addUp svgElement, onUp
#
#       keyBehaviourId = 0
#       keyDown = false
#
#       svgElement.addEventListener "keydown", (e)->
#         return if keyDown
#         if e.keyCode is behaviourCode
#           e.preventDefault()
#           keyDown = true
#           keyBehaviourId = setInterval addBehaviour, 16
#
#       svgElement.addEventListener "keyup", (e)->
#         if e.keyCode is behaviourCode
#           e.preventDefault()
#           releaseBehaviour()
#           clearInterval keyBehaviourId
#           keyDown = false
#
#     Make "SVGCamera", SVGCamera = (svgElement, mainStage, navOverlay, control)->
#       return scope =
#         baseX: 0
#         baseY: 0
#         centerX: 0
#         maxZoom: 8.0
#         minZoom: 1.0
#         acceleration: 0.125
#         centerY: 0
#         transX: 0
#         transY: 0
#         scaleAdjustY: 0
#         baseWidth: 0
#         baseHeight: 0
#         zoom: 1
#         open: false
#         currentTime: null
#         mainStage: null
#         transValue : 800
#         navOverlay: null
#         velocity: null
#         upKey: false
#         downKey: false
#         leftKey: false
#         rightKey: false
#         releaseInY: false
#         releaseInX: false
#         releaseInZ: false
#
#
#         setup: ()->
#           parent = mainStage.root
#           properties = parent.getElement().getAttribute("viewBox").split(" ")
#           scope.viewWidth = parseFloat(properties[2])
#           scope.viewHeight = parseFloat(properties[3])
#           scope.velocity = {x:0, y: 0, z: 0}
#           scope.mainStage = mainStage
#
#           navOverlay.style.show(false)
#
#           control.getElement().addEventListener "click", scope.toggle
#
#           navOverlay.reset.getElement().addEventListener "click", ()->
#             scope.zoomToPosition(1, 0, 0)
#
#           navOverlay.close.getElement().addEventListener "click", scope.toggle
#
#           setupElementWithFunction svgElement, navOverlay.up.getElement(), 38, scope.up, ()->
#             scope.velocity.y = 1.0
#             scope.upKey = false
#             scope.releaseInY = true if not (scope.downKey or scope.upKey)
#
#           setupElementWithFunction svgElement, navOverlay.down.getElement(), 40, scope.down, ()->
#             scope.velocity.y = -1.0
#             scope.downKey = false
#             scope.releaseInY = true if not (scope.downKey or scope.upKey)
#
#           setupElementWithFunction svgElement, navOverlay.left.getElement(), 37, scope.left, ()->
#             scope.velocity.x = 1.0
#             scope.leftKey = false
#             scope.releaseInX = true if not (scope.leftKey or scope.rightKey)
#
#           setupElementWithFunction svgElement, navOverlay.right.getElement(), 39, scope.right, ()->
#             scope.velocity.x = -1.0
#             scope.rightKey = false
#             scope.releaseInX = true if not (scope.leftKey or scope.rightKey)
#
#           setupElementWithFunction svgElement, navOverlay.plus.getElement(),187, scope.plus, ()->
#             scope.plusKey = false
#             scope.releaseInZ = true if not (scope.plusKey or scope.minusKey)
#
#           setupElementWithFunction svgElement, navOverlay.minus.getElement(), 189, scope.minus, ()->
#             scope.minusKey = false
#             scope.releaseInZ = true if not (scope.plusKey or scope.minusKey)
#
#           svgElement.addEventListener "keydown", (e)->
#             # This gives an output for positions to later put into POI
#             if e.keyCode is 88 # x
#               console.log "setTransformation(#{scope.transX}, #{scope.transY}, #{scope.zoom})"
#
#           scope.handleScaling()
#           RequestUniqueAnimation(scope.updateAnimation)
#
#         toggle: ()->
#           scope.open = !scope.open
#           if scope.open
#             navOverlay.style.show(true)
#           else
#             navOverlay.style.show(false)
#
#         up:    ()-> scope.upKey    = true
#         down:  ()-> scope.downKey  = true
#         left:  ()-> scope.leftKey  = true
#         right: ()-> scope.rightKey = true
#
#         updateAnimation: (time)->
#           scope.currentTime = time if scope.currentTime is null
#           dT = (time - scope.currentTime) / 1000
#           scope.currentTime = time
#           if scope.downKey and not scope.upKey
#             scope.velocity.y = 0 if scope.velocity.y > 0
#             scope.velocity.y -= scope.acceleration if Math.abs(scope.velocity.y) <= 1
#           if scope.upKey and not scope.downKey
#             scope.velocity.y = 0 if scope.velocity.y < 0
#             scope.velocity.y += scope.acceleration if Math.abs(scope.velocity.y) <= 1
#           if scope.rightKey and not scope.leftKey
#             scope.velocity.x = 0 if scope.velocity.x > 0
#             scope.velocity.x -= scope.acceleration if Math.abs(scope.velocity.x) <= 1
#           if scope.leftKey and not scope.rightKey
#             scope.velocity.x = 0 if scope.velocity.x < 0
#             scope.velocity.x += scope.acceleration if Math.abs(scope.velocity.x) <= 1
#           if scope.plusKey and not scope.minusKey
#             scope.velocity.z = 0 if scope.velocity.x < 0
#             scope.velocity.z += scope.acceleration if Math.abs(scope.velocity.z) <= 1
#           if scope.minusKey and not scope.plusKey
#             scope.velocity.z = 1 if scope.velocity.z > 0
#             scope.velocity.z -= scope.acceleration if Math.abs(scope.velocity.z) <= 1
#
#           scope.updatePosition(dT)
#           RequestUniqueAnimation(scope.updateAnimation)
#
#         updatePosition: (dT)->
#           rightStop = svgElement.getBoundingClientRect().width / 2
#           leftStop = -svgElement.getBoundingClientRect().width / 2
#           scope.releaseX(dT) if scope.releaseInX
#           scope.releaseY(dT) if scope.releaseInY
#           scope.releaseZ(dT) if scope.releaseInZ
#
#           length = Math.sqrt(scope.velocity.x * scope.velocity.x + scope.velocity.y * scope.velocity.y)
#           length = 1 if scope.velocity.x is 0 and scope.velocity.y is 0
#           vX = scope.velocity.x
#           vX /= length if length > 1
#           scope.transX += (vX * scope.transValue * dT) / scope.zoom
#           vY = scope.velocity.y
#           vY /= length if length > 1
#           scope.transY += (vY * scope.transValue * dT) / scope.zoom
#           vZ = scope.velocity.z
#           scope.zoom += (vZ * scope.getZoomIncrease() * 75 * dT) / (scope.zoom)
#           scope.boundX()
#           scope.boundY()
#           scope.boundZ()
#
#         boundX: ()->
#           rightStop = svgElement.getBoundingClientRect().width / 2
#           leftStop = -svgElement.getBoundingClientRect().width / 2
#           scope.transX = leftStop if scope.transX < leftStop
#           scope.transX = rightStop if scope.transX > rightStop
#           scope.mainStage.transform.x = scope.transX
#
#         boundY: ()->
#           # upStop = svgElement.getBoundingClientRect().height / 2
#           # downStop = -svgElement.getBoundingClientRect().height / 2
#           # scope.transY = downStop if scope.transY < downStop
#           # scope.transY = upStop if scope.transY > upStop
#           scope.mainStage.transform.y = scope.transY
#         boundZ: ()->
#           if scope.zoom < scope.minZoom
#             scope.zoom = scope.minZoom
#           if scope.zoom > scope.maxZoom
#             scope.zoom = scope.maxZoom
#           scope.mainStage.transform.scale = scope.zoom
#
#
#         releaseX: (dT)->
#           if scope.downKey or scope.upKey or scope.rightKey or scope.downKey
#             scope.releaseInX = false
#             scope.velocity.x = 0
#             return
#           if scope.velocity.x < 0
#             scope.velocity.x += scope.acceleration
#             if scope.velocity.x >= 0
#               scope.velocity.x = 0
#               scope.releaseInX = false
#           else if scope.velocity.x > 0
#             scope.velocity.x -= scope.acceleration
#             if scope.velocity.x <= 0
#               scope.velocity.x = 0
#               scope.releaseInX = false
#
#         releaseY: (dT)->
#           if scope.downKey or scope.upKey or scope.rightKey or scope.downKey
#             scope.releaseInY = false
#             scope.velocity.y = 0
#             return
#           if scope.velocity.y < 0
#             scope.velocity.y += scope.acceleration
#             if scope.velocity.y >= 0
#               scope.velocity.y = 0
#               scope.releaseInY = false
#           else if scope.velocity.y > 0
#             scope.velocity.y -= scope.acceleration
#             if scope.velocity.y <= 0
#               scope.velocity.y = 0
#               scope.releaseInY = false
#         releaseZ: (dT)->
#           if scope.plusKey or scope.minusKey
#             scope.releaseInZ = false
#             scope.velocity.z = 0
#             return
#           if scope.velocity.z < 0
#             scope.velocity.z += scope.acceleration
#             if scope.velocity.z >= 0
#               scope.velocity.z = 0
#               scope.releaseInZ = false
#           else if scope.velocity.z > 0
#             scope.velocity.z -= scope.acceleration
#             if scope.velocity.z <= 0
#               scope.velocity.z = 0
#               scope.releaseInZ = false
#         plus: ()->
#           scope.plusKey = true
#         minus: ()->
#           scope.minusKey = true
#
#         transform: (x, y, scale)->
#           scope.zoom = scale
#           scope.mainStage.transform.scale = scope.zoom
#           scope.transX = x
#           scope.mainStage.transform.x = scope.transX
#           scope.transY = y
#           scope.mainStage.transform.y = scope.transY
#
#         smoothTransformProperty: (property, start, end)->
#           timeToTransform = 1
#           currentTime = null
#           totalTime = 0
#           transformProperty = (time)->
#             currentTime = time if not currentTime?
#             totalTime += (time - currentTime) / 1000
#             currentTime = time
#
#             newValue = Ease.cubic(totalTime, 0, timeToTransform, start, end)
#             scope[property] = newValue
#             scope.setViewBox()
#
#             if totalTime < timeToTransform
#               RequestUniqueAnimation(transformProperty)
#           RequestUniqueAnimation(transformProperty)
#
#
#         getZoomIncrease: ()->
#           zoomSpeed = 0.03
#           zoomIncrease = zoomSpeed * scope.zoom
#           return zoomIncrease
#
#         setViewBox: ()->
#           if scope.zoom < scope.maxZoom
#             scope.zoom = scope.maxZoom
#           if scope.zoom > scope.minZoom
#             scope.zoom = scope.minZoom
#           ntX = scope.transX * scope.zoom
#           ntY = scope.transY * scope.zoom
#           ncX = (scope.centerX + scope.transX) - (scope.centerX + scope.transX) * scope.zoom
#           ncY = (scope.centerY + scope.transY) - (scope.centerY + scope.transY) * scope.zoom
#           svgElement.setAttribute("viewBox", "#{ncX + ntX} #{ncY + ntY} #{scope.baseWidth * scope.zoom} #{scope.baseHeight * scope.zoom}")
#
#         zoomToPosition: (newZoom, newX, newY)->
#           currentTime = null
#           increaseScale = 2
#           increaseTransform = 80
#           timeElapsed = 0
#           xDiff = Math.abs(scope.transX - newX)
#           yDiff = Math.abs(scope.transY - newY)
#           scaleDiff = Math.abs(scope.zoom - newZoom)
#           xDone = false
#           yDone = false
#
#           zoomDone = false
#           easeFunction = Ease.quartic
#           animateToPosition = (time)->
#             if currentTime is null
#               currentTime = time
#             delta = (time - currentTime) / 1000
#             currentTime = time
#             timeElapsed += delta
#             scope.mainStage.transform.x = easeFunction(timeElapsed * increaseTransform, 0, xDiff, scope.transX, newX)
#             if timeElapsed * increaseTransform >= xDiff
#               xDone = true
#               scope.transX = newX
#               scope.mainStage.transform.x = scope.transX
#             scope.mainStage.transform.y = easeFunction(timeElapsed * increaseTransform, 0, yDiff, scope.transY, newY)
#             if timeElapsed * increaseTransform >= yDiff
#               yDone = true
#               scope.transY = newY
#               scope.mainStage.transform.y = scope.transY
#
#             scope.mainStage.transform.scale = easeFunction(timeElapsed * increaseScale, 0, scaleDiff, scope.zoom, newZoom)
#             if timeElapsed * increaseScale > scaleDiff
#               zoomDone = true
#               scope.zoom = newZoom
#               scope.mainStage.transform.scale = scope.zoom
#
#             if not (xDone and yDone and zoomDone)
#               RequestUniqueAnimation animateToPosition
#
#           RequestUniqueAnimation animateToPosition
#
#         handleScaling: ()->
#           onResize = ()->
#             boundingRect = mainStage.root.getElement().getBoundingClientRect()
#             rectHeight = boundingRect.height
#             navBox = navOverlay.getElement().getBoundingClientRect()
#             navScaleX = window.innerWidth / 2 / navBox.width
#             navScaleY = window.innerHeight / 2 / navBox.height
#             navScale = Math.min(navScaleX, navScaleY)
#             navOverlay.transform.scale *= navScale
#             newMinZoom = (rectHeight - mainStage.root._controlPanel.panelHeight - 10) / rectHeight
#             newMinZoom = Math.abs(newMinZoom)
#             if scope.zoom is scope.minZoom
#               scope.zoom = newMinZoom
#             transAmount = (1.0 - newMinZoom) * scope.viewHeight / 2
#             scope.transY -= scope.scaleAdjustY #use old scale adjustment
#             navOverlay.transform.y -= scope.scaleAdjustY
#             scope.scaleAdjustY = -transAmount
#             scope.transY += scope.scaleAdjustY
#             navOverlay.transform.y += scope.scaleAdjustY
#             scope.minZoom = newMinZoom
#
#           onResize()
#           window.addEventListener "resize", onResize
