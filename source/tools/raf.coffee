# RAF is used for 1-time requestAnimationFrame callbacks.
# For every-frame requestAnimationFrame callbacks, use system/tick.coffee

do ()->
  allReady = false
  runRequested = false
  aboutToRun = false
  callbacksByPriority = [[],[]] # Assume 2 priorities will be used in most cases
  
  
  run = (time)->
    aboutToRun = false
    for callbacks, priority in callbacksByPriority when callbacks?
      callbacksByPriority[priority] = []
      cb time for cb in callbacks
    
    undefined
  
  
  attemptToRun = ()->
    if allReady and runRequested
      if not aboutToRun
        aboutToRun = true
        requestAnimationFrame run
  
  
  Take "AllReady", ()->
    allReady = true
    attemptToRun()
  
  
  Make "RAF", (cb, ignoreDuplicates = false, priority = 0)->
    throw new Error "RAF(null)" unless cb?
    
    for c in callbacksByPriority[priority] when c is cb
      return if ignoreDuplicates
      console.log cb
      throw new Error "^ RAF was called more than once with this function. You can use RAF(fn, true) to drop duplicates and bypass this error."
    
    (callbacksByPriority[priority] ?= []).push cb
    
    runRequested = true
    attemptToRun()
    
    cb # Composable
