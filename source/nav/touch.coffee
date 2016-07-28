Take ["Nav"], (Nav)->
  
  lastX = 0
  lastY = 0
  
  
  
  window.addEventListener "touchstart", touchStart = (e)->
    if e.touches.length is 1 and Nav.eventInside e
      e.preventDefault()
      lastX = e.touches[0].clientX
      lastY = e.touches[0].clientY
  
  window.addEventListener "touchmove", touchMove = (e)->
    if e.touches.length is 1 and Nav.eventInside e
      e.preventDefault()
      newX = e.touches[0].clientX
      newY = e.touches[0].clientY
      Nav.by
        x: newX - lastX
        y: newY - lastY
      lastX = newX
      lastY = newY
  
  # window.addEventListener "pointermove", (e)->
  #   console.log e
