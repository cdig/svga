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
  
  Make "Tick", (cb)->
    callbacks.push cb
    cb # Composable
