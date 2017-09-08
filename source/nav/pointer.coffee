Take ["Mode", "Nav", "SVG"], (Mode, Nav, SVG)->
  return unless Mode.nav
  return unless navigator.msMaxTouchPoints and navigator.msMaxTouchPoints > 1
  
  gesture = new MSGesture()
  gesture.target = SVG.svg
  
  gesture.target.addEventListener "pointerdown", (e)->
    if Nav.eventInside e
      gesture.addPointer e.pointerId

  gesture.target.addEventListener "MSGestureChange", (e)->
    if Nav.eventInside e
      e.preventDefault()
      Nav.by z: Math.log2 e.scale
