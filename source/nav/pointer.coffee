Take ["Nav"], (Nav)->
  
  return unless navigator.msMaxTouchPoints and navigator.msMaxTouchPoints > 1
  gesture = new MSGesture()
  gesture.target = document.rootElement
  
  gesture.target.addEventListener "pointerdown", (e)->
    if Nav.eventInside e
      e.preventDefault() if touches > 0
      gesture.addPointer e.pointerId

  gesture.target.addEventListener "MSGestureChange", (e)->
    if Nav.eventInside e
      e.preventDefault()
      Nav.by z: Math.log2(e.scale)
