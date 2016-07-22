# Take ["GUI","KeyMe","Reaction","RAF","Resize","SVG","TRS","Tween","Tween1","ScopeReady"],
# (      GUI , KeyMe , Reaction , RAF , Resize , SVG , TRS , Tween , Tween1)->
#
#
#   touches = null
#
#   touchStart = (e)->
#     return unless eventInside e.touches[0].clientX, e.touches[0].clientY
#     e.preventDefault()
#     touches = cloneTouches e
#     vel.d = vel.z = 0
#     window.addEventListener "touchmove", touchMove
#     window.addEventListener "touchend", touchEnd
#
#
#   touchMove = (e)->
#     e.preventDefault()
#     if e.touches.length isnt touches.length
#       # noop
#     else if e.touches.length > 1
#       a = distTouches touches
#       b = distTouches e.touches
#       pos.z += (b - a) / 200
#       pos.z = Math.min maxZoom, Math.max minZoom, pos.z
#     else
#       pos.x += (e.touches[0].clientX - touches[0].clientX) / (base.z * Math.pow 2, pos.z)
#       pos.y += (e.touches[0].clientY - touches[0].clientY) / (base.z * Math.pow 2, pos.z)
#     touches = cloneTouches e
#     RAF render, true
#
#   touchEnd = (e)->
#     if touches.length <= 1
#       window.removeEventListener "touchmove", touchMove
#       window.removeEventListener "touchend", touchEnd
#
#
#   cloneTouches = (e)->
#     for t in e.touches
#       clientX: t.clientX
#       clientY: t.clientY
#
#
#
#
#   to = (x, y, z)->
#     target =
#       x: if x? then x else pos.x
#       y: if y? then y else pos.y
#       z: if z? then z else pos.z
#     time = Math.sqrt(distTo pos, target) / 30
#     if time > 0
#       Tween on:pos, to:target, time: time, tick: render
#
#
#   distTouches = (touches)->
#     a = touches[0]
#     b = touches[1]
#     dx = a.clientX - b.clientX
#     dy = a.clientY - b.clientY
#     dist dx, dy
#
#   distTo = (a, b)->
#     dx = a.x - b.x
#     dy = a.y - b.y
#     dz = 200 * a.z - b.z
#     dist dx, dy, dz
#
#   dist = (x, y, z = 0)->
#     Math.sqrt x*x + y*y + z*z
#
#
#   eventInside = (x, y)->
#     panelHidden = false # !Control.panelShowing # TODO
#     insidePanel = x < window.innerWidth - GUI.ControlPanel.width
#     insideTopBar = y > GUI.TopBar.height
#     return insideTopBar and (panelHidden or insidePanel)


  # window.addEventListener "touchstart", touchStart
