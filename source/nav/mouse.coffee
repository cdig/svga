Take ["Nav", "TweenNav"], (Nav, TweenNav)->
  
  window.addEventListener "dblclick", (e)->
    if Nav.eventInside e.clientX, e.clientY
      e.preventDefault()
      TweenNav x:0, y:0, z:0
  
  window.addEventListener "wheel", (e)->
    if Nav.eventInside e.clientX, e.clientY
      e.preventDefault()
      if e.ctrlKey # Chrome, pinch-to-zoom
        Nav.by z: -e.deltaY / 100
      else if e.metaKey # Other browsers, meta+scroll zoom
        Nav.by z: -e.deltaY / 200
      else
        Nav.by
          x: -e.deltaX
          y: -e.deltaY
          z: -e.deltaZ
