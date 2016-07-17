do ()->
  Make "Input", (elm, calls)->
    state =
      down: false
      over: false
      touch: false
    
    over = (e)->
      state.over = true
      calls.over? e
    
    down = (e)->
      state.down = true
      calls.down? e
    
    move = (e)->
      if state.down and calls.drag?
        calls.drag e
      else
        calls.move? e
    
    up = (e)->
      state.down = false
      if state.over
        calls.click? e
      else
        calls.miss? e
      calls.up? e
    
    out = (e)->
      state.over = false
      calls.out? e
    
    
    # MOUSE #####################################################################################
    
    elm.addEventListener "mouseenter", (e)->
      return if state.touch
      # console.log "mouseenter"
      over e
      elm.addEventListener "mouseleave", mouseleave
    
    elm.addEventListener "mousedown", (e)->
      return if state.touch
      # console.log "mousedown"
      down e
      elm.addEventListener "mousemove", mousemove
      window.addEventListener "mouseup", mouseup
    
    mousemove = (e)->
      return if state.touch
      # console.log "mousemove"
      move e
    
    mouseup = (e)->
      return if state.touch
      # console.log "mouseup"
      up e
      elm.removeEventListener "mousemove", mousemove
      window.removeEventListener "mouseup", mouseup
    
    mouseleave = (e)->
      return if state.touch
      # console.log "mouseleave"
      out e
      elm.removeEventListener "mouseleave", mouseleave
    
    # TOUCH #####################################################################################
    
    prepTouchEvent = (e)->
      state.touch = true
      e.clientX = e.touches[0]?.clientX
      e.clientY = e.touches[0]?.clientY
    
    elm.addEventListener "touchstart", (e)->
      # console.log "touchstart"
      prepTouchEvent e
      over e
      down e
      elm.addEventListener "touchmove", touchmove
      elm.addEventListener "touchend", touchend
      elm.addEventListener "touchcancel", touchend
    
    touchmove = (e)->
      # console.log "touchmove"
      prepTouchEvent e
      # Not sure how to do this properly. Not trivial.
      # isOver = elm is e.currentTarget or elm.contains e.currentTarget
      isOver = true
      over e if isOver and not state.over
      move e if isOver
      out e if not isOver and state.over
    
    touchend = (e)->
      # console.log "touchend"
      prepTouchEvent e
      up e
      elm.removeEventListener "touchmove", touchmove
      elm.removeEventListener "touchend", touchend
      elm.removeEventListener "touchcancel", touchend
