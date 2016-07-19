# Tick is used for every-frame requestAnimationFrame callbacks.
# For 1-time requestAnimationFrame callbacks, use system/raf.coffee

Take "RAF", (RAF)->
  callbacks = []
  time = (performance?.now() or 0)/1000
  
  RAF tick = (t)->
    dt = t/1000 - time
    time += dt
    cb time, dt for cb in callbacks
    RAF tick
  
  Make "Tick", (cb, ignoreDuplicates = false)->
    for c in callbacks when c is cb
      return if ignoreDuplicates
      console.log cb
      throw "^ Tick was called more than once with this function. You can use Tick(fn, true) to drop duplicates and bypass this error."
    
    callbacks.push cb
    cb # Composable
