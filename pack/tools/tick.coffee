# Tick is used for every-frame requestAnimationFrame callbacks.
# For 1-time requestAnimationFrame callbacks, use system/raf.coffee

Take ["ParentObject", "RAF"], (ParentObject, RAF)->
  # We go all the way down to 2 FPS, but no lower, to avoid weirdness if the JS thread is paused.
  # Below 2 FPS, we'll start to get temporal skew where the internal time and the wall time diverge.
  minimumDT = 0.5
  callbacks = []
  wallTime = (performance?.now() or 0)/1000
  internalTime = 0
  
  RAF tick = (t)->
    dt = Math.min t/1000 - wallTime, minimumDT
    wallTime = t/1000
    if not ParentObject.disableSVGA # disableSVGA is set automatically by cd-module when the SVGA is offscreen
      internalTime += dt
      cb internalTime, dt for cb in callbacks
    RAF tick
  
  Make "Tick", (cb, ignoreDuplicates = false)->
    for c in callbacks when c is cb
      return if ignoreDuplicates
      console.log cb
      throw new Error "^ Tick was called more than once with this function. You can use Tick(fn, true) to drop duplicates and bypass this error."
    
    callbacks.push cb
    cb # Composable
