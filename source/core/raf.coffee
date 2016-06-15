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
  
  
  Make "RequestDeferredRender", (cb, ignoreDuplicates = false)->
    return console.log "Warning: RequestDeferredRender(null)" unless cb?
    
    for c in deferredCallbacks when c is cb
      return if ignoreDuplicates
      @RDRDuplicate = cb
      return console.log "Warning: RequestDeferredRender was called with the same function more than once. To figure out which function, please run `RDRDuplicate` in the browser console."
    
    deferredCallbacks.push cb

    if not requested
      requested = true
      requestAnimationFrame run
  
  
  Make "RequestUniqueAnimation", (cb, ignoreDuplicates = false)->
    return console.log "Warning: RequestUniqueAnimation(null)" unless cb?
    
    for c in rafCallbacks when c is cb
      return if ignoreDuplicates
      @RUADuplicate = cb
      return console.log "Warning: RequestUniqueAnimation was called with the same function more than once.  To figure out which function, please run `RUADuplicate` in the browser console."
    
    rafCallbacks.push cb
    
    if not requested
      requested = true
      requestAnimationFrame run
