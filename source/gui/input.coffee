do ()->
  Make "Input", (elm, calls)->
    state =
      down: false
      over: false
    
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
      over e
      elm.addEventListener "mouseleave", mouseleave
    
    elm.addEventListener "mousedown", (e)->
      down e
      elm.addEventListener "mousemove", mousemove
      window.addEventListener "mouseup", mouseup
    
    mousemove = (e)->
      move e
    
    mouseup = (e)->
      up e
      elm.removeEventListener "mousemove", mousemove
      window.removeEventListener "mouseup", mouseup
    
    mouseleave = (e)->
      out e
      elm.removeEventListener "mouseleave", mouseleave
    
    # TOUCH #####################################################################################
    
    elm.addEventListener "touchstart", (e)->
      over e
      down e
      elm.addEventListener "touchmove", touchmove
      elm.addEventListener "touchend", touchend
      elm.addEventListener "touchcancel", touchend
    
    touchmove = (e)->
      # Not sure how to do this properly. Not trivial.
      # isOver = elm is e.currentTarget or elm.contains e.currentTarget
      isOver = true
      over e if isOver and not state.over
      move e if isOver
      out e if not isOver and state.over
    
    touchend = (e)->
      up e
      elm.removeEventListener "touchmove", touchmove
      elm.removeEventListener "touchend", touchend
      elm.removeEventListener "touchcancel", touchend
