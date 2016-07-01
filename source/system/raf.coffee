do ()->
  requested = false
  callbacksByPriority = [[],[]] # Assume 2 priorities will be used in most cases
  
  
  run = (time)->
    requested = false
    
    for callbacks, p in callbacksByPriority when callbacks?
      callbacksByPriority[p] = []
      cb time for cb in callbacks
  
  
  Make "RAF", (cb, ignoreDuplicates = false, p = 0)->
    throw "RAF(null)" unless cb?
    
    for c in callbacksByPriority[p] when c is cb
      return if ignoreDuplicates
      console.log cb
      throw "^ RAF was called more than once with this function. You can use RAF(fn, true) to drop duplicates and bypass this error."
    
    (callbacksByPriority[p] ?= []).push cb
    
    if not requested
      requested = true
      requestAnimationFrame run
    
    cb # Composable
