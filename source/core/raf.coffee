do ()->
  requested = false
  rafCallbacks = []
  deferredCallbacks = []
  
  
  run = (t)->
    requested = false
    
    _cbs = rafCallbacks
    rafCallbacks = []
    cb(t) for cb in _cbs
    
    _cbs = deferredCallbacks
    deferredCallbacks = []
    cb() for cb in _cbs
    
  
  Make "RequestDeferredRender", (cb)->
    return console.log "Warning: RequestDeferredRender(null)" unless cb?
    
    for c in rafCallbacks when c is cb
      console.log "Warning: RequestDeferredRender was called with the same function more than once:"
      return console.log cb
      
    deferredCallbacks.push cb
  
  
  Make "RequestUniqueAnimation", (cb)->
    return console.log "Warning: RequestUniqueAnimation(null)" unless cb?
    
    for c in rafCallbacks when c is cb
      console.log "Warning: RequestUniqueAnimation was called with the same function more than once:"
      return console.log cb
    
    rafCallbacks.push cb
    
    if not requested
      requested = true
      requestAnimationFrame run
