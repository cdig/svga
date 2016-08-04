do ()->
  Make "Input", (elm, calls)->
    state =
      down: false
      over: false
      touch: false
    
    over = (e)->
      state.over = true
      calls.over? e, state
      if state.down
        calls.down? e, state
    
    down = (e)->
      state.down = true
      calls.down? e, state
    
    move = (e)->
      if not state.over
        over e
      if state.down and calls.drag?
        calls.drag e, state
      else
        calls.move? e, state
    
    up = (e)->
      state.down = false
      if state.over
        calls.click? e, state
      else
        calls.miss? e, state
      calls.up? e, state
    
    out = (e)->
      state.over = false
      calls.out? e, state
    
    
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
      window.addEventListener "mouseup", mouseup
    
    elm.addEventListener "mousemove", (e)->
      return if state.touch
      # console.log "mousemove"
      move e
    
    mouseup = (e)->
      return if state.touch
      # console.log "mouseup"
      up e
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
