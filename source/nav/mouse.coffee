# Take ["GUI","KeyMe","Reaction","RAF","Resize","SVG","TRS","Tween","Tween1","ScopeReady"],
# (      GUI , KeyMe , Reaction , RAF , Resize , SVG , TRS , Tween , Tween1)->
#
#
#   dblclick = (e)->
#     if eventInside e.clientX, e.clientY
#       e.preventDefault()
#       to 0, 0, 0
#
#   wheel = (e)->
#     return unless eventInside e.clientX, e.clientY
#     e.preventDefault()
#     if e.ctrlKey # Chrome, pinch-to-zoom
#       pos.z -= e.deltaY / 100
#     else if e.metaKey # Other browsers, meta+scroll zoom
#       pos.z -= e.deltaY / 200
#     else
#       pos.x -= e.deltaX / (base.z * Math.pow 2, pos.z)
#       pos.y -= e.deltaY / (base.z * Math.pow 2, pos.z)
#       pos.z -= e.deltaZ
#     RAF render, true
  
  
  # window.addEventListener "dblclick", dblclick
  # window.addEventListener "wheel", wheel
