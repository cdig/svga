Make "Input", (elm, calls, mouse = true, touch = true, options = {})->
  enabled = true
  state = null
  
  # Thanks, Chrome..v_v
  touchListenerOptions = passive: not options.blockScroll
  
  resetState = ()->
    state =
      down: false
      over: false
      touch: false
      clicking: false
      captured: false
      deltaX: 0
      deltaY: 0
      lastX: 0 # These are used to compute deltas..
      lastY: 0 # and to avoid repeat unchanged move events on IE
  
  resetState()
  
  down = (e)->
    state.lastX = e.clientX
    state.lastY = e.clientY
    state.deltaX = 0
    state.deltaY = 0
    if not state.down
      state.down = true
      if state.over
        state.clicking = true
        calls.down? e, state
      else
        calls.downOther? e, state
  
  up = (e)->
    if state.down
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
    return if e.clientX is state.lastX and e.clientY is state.lastY
    state.deltaX = e.clientX - state.lastX
    state.deltaY = e.clientY - state.lastY
    if state.over
      if state.down
        e.preventDefault() if options.blockScroll and state.touch
        calls.drag? e, state
      else
        calls.move? e, state
    else
      if state.down
        calls.dragOther? e, state
      else
        calls.moveOther? e, state
    state.lastX = e.clientX
    state.lastY = e.clientY
  
  out = (e)->
    if state.over
      state.over = false
      if state.down
        calls.dragOut? e, state
      else
        calls.moveOut? e, state
  
  over = (e)->
    state.lastX = e.clientX
    state.lastY = e.clientY
    if not state.over
      state.over = true
      if state.down
        calls.dragIn? e, state
      else
        calls.moveIn? e, state
  
  
  # MOUSE #####################################################################################
  
  if mouse
  
    document.addEventListener "mousedown", (e)->
      return unless enabled
      return unless e.button is 0
      return if state.touch
      down e
  
    # Windows fires this event every tick when touch-dragging, even when the input doesn't move?
    # Only add the move listener if we need it, to avoid the perf cost
    if calls.move? or calls.drag? or calls.moveOther? or calls.dragOther?
      document.addEventListener "mousemove", (e)->
        return unless enabled
        return if state.touch
        move e
  
    document.addEventListener "mouseup", (e)->
      return unless enabled
      return unless e.button is 0
      return if state.touch
      up e
  
    if elm?
      elm.addEventListener "mouseleave", (e)->
        return unless enabled
        return if state.touch
        out e
  
    if elm?
      elm.addEventListener "mouseenter", (e)->
        return unless enabled
        return if state.touch
        over e
  
  
  # TOUCH #####################################################################################
  
  if touch
  
    prepTouchEvent = (e)->
      state.touch = true
      e.clientX = e.touches[0]?.clientX
      e.clientY = e.touches[0]?.clientY
      if elm? and e.clientX? and e.clientY? and (state.captured is null or state.captured is true)
        pElm = document.elementFromPoint e.clientX, e.clientY
        newState = elm is pElm or elm.contains pElm
        overChanged = newState isnt state.over
        if overChanged
          if newState
            state.captured ?= true
            over e
          else
            out e
      state.captured ?= false
  
    touchstart = (e)->
      return unless enabled
      state.captured = null
      prepTouchEvent e
      down e
    document.addEventListener "touchstart", touchstart, touchListenerOptions
  
    # Windows fires this event every tick when touch-dragging, even when the input doesn't move?
    # Only add the move listener if we need it, to avoid the perf cost
    if calls.move? or calls.drag? or calls.moveOther? or calls.dragOther? or calls.moveIn? or calls.dragIn? or calls.moveOut? or calls.dragOut?
      touchmove = (e)->
        return unless enabled
        prepTouchEvent e
        move e
      document.addEventListener "touchmove", touchmove, touchListenerOptions
  
    document.addEventListener "touchend", (e)->
      return unless enabled
      prepTouchEvent e
      e.preventDefault() # This avoids redundant mouse events, which double-fire click handlers
      up e
      state.touch = false
  
    document.addEventListener "touchcancel", (e)->
      return unless enabled
      prepTouchEvent e
      up e
      state.touch = false


  return api =
    enable: (_enabled)->
      enabled = _enabled
      resetState() if !enabled
      
