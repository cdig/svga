Make "Input", (elm, calls)->
  state =
    down: false
    over: false
    touch: false
    clicking: false
  
  
  down = (e)->
    state.down = true
    if state.over
      state.clicking = true
      calls.down? e, state
    else
      calls.downOther? e, state
  
  up = (e)->
    state.down = false
    if state.over
      calls.up? e, state
      if state.clicking
        state.clicking = false
        calls.click? e, state
    else
      calls.upOther? e, state
      if state.clicking
        state.clicking = false
        calls.miss? e, state
  
  move = (e)->
    if state.over
      if state.down
        calls.drag? e, state
      else
        calls.move? e, state
    else
      if state.down
        calls.dragOther? e, state
      else
        calls.moveOther? e, state
  
  out = (e)->
    state.over = false
    if state.down
      calls.dragOut? e, state
    else
      calls.moveOut? e, state
  
  over = (e)->
    state.over = true
    if state.down
      calls.dragIn? e, state
    else
      calls.moveIn? e, state
  
  
  # MOUSE #####################################################################################
  
  window.addEventListener "mousedown", (e)->
    return if state.touch
    down e
  
  # Only add the move listener if we need it, to avoid the perf cost
  if calls.move? or calls.drag? or calls.moveOther? or calls.dragOther?
    window.addEventListener "mousemove", (e)->
      return if state.touch
      move e
  
  window.addEventListener "mouseup", (e)->
    return if state.touch
    up e
  
  elm.addEventListener "mouseleave", (e)->
    return if state.touch
    out e
  
  elm.addEventListener "mouseenter", (e)->
    return if state.touch
    over e
  
  # TOUCH #####################################################################################
  
  prepTouchEvent = (e)->
    state.touch = true
    e.clientX = e.touches[0]?.clientX
    e.clientY = e.touches[0]?.clientY
    if e.clientX? and e.clientY?
      pElm = document.elementFromPoint e.clientX, e.clientY
      newState = elm is pElm or elm.contains pElm
      overChanged = newState isnt state.over
      state.over = newState
      if overChanged
        if state.over
          over e
        else
          out e

  window.addEventListener "touchstart", (e)->
    prepTouchEvent e
    down e
  
  # Only add the move listener if we need it, to avoid the perf cost
  if calls.move? or calls.drag? or calls.moveOther? or calls.dragOther? or calls.moveIn? or calls.dragIn? or calls.moveOut? or calls.dragOut?
    window.addEventListener "touchmove", (e)->
      prepTouchEvent e
      move e
  
  window.addEventListener "touchend", (e)->
    prepTouchEvent e
    up e

  window.addEventListener "touchcancel", (e)->
    prepTouchEvent e
    up e
