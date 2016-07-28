# Tween
# This is just a really dumb value interpolator

Take ["Tick"], (Tick)->
  tweens = []
  
  Tween = (from, to, time, opts, next)->
    
    # Allow the 4th arg to just be a tick function, rather than an options object.
    if typeof opts is "function"
      tween = tick: opts
    else
      tween = opts
    
    tween.from = from
    tween.to = to
    tween.time = time
    tween.next = next if next? # Allow the 5th arg to be optional
    
    tween.pos ?= 0
    tween.ease ?= "easeInOut"
    
    tween.value = 0
    tween.delta = to - from
    tween.cancelled = false
    
    # Now is a great time to do some GC
    gc tween.tick, tween.next
    
    tweens.push tween
    tween # Composable
  
  Tick (t, dt)->
    for tween in tweens when not tween.cancelled
      if tween.pos < 1
        tween.pos += dt / tween.time
        tween.value = tween.from + tween.delta * cubic Math.min 1, tween.pos
        tween.tick tween.value, tween
      else if tween.next?
        tweens.push tween.next
        tween.next = null
  
  gc = (tick, next)->
    tweens = tweens.filter (tween)->
      return false if tween.pos >= 1
      return false if tween.cancelled
      return false if tween.tick is tick
      return false if next? and tween is next
      return true
  
  cubic = (input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true)->
    return outputMin if inputMin is inputMax # Avoids a divide by zero
    input = Math.max inputMin, Math.min inputMax, input if clip
    outputDiff = outputMax - outputMin
    inputDiff = inputMax - inputMin
    p = (input-inputMin) / (inputDiff/2)
    power = 3
    if p < 1
      return outputMin + outputDiff/2 * Math.pow(p, power)
    else
      return outputMin + outputDiff/2 * (2 - Math.abs(Math.pow(p-2, power)))

  
  # You can pass as many callbacks as you want to this. We'll stop calling them.
  Tween.cancel = gc
    
  Make "Tween", Tween
