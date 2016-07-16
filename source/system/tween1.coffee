# Tween1
# This is just a really dumb value interpolator

Take ["Ease", "Tick"], (Ease, Tick)->
  tweens = []
  
  Tween1 = (from, to, time, opts, next)->
    
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
        tween.value = tween.from + tween.delta * Ease.cubic Math.min 1, tween.pos
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
  
  
  # You can pass as many callbacks as you want to this. We'll stop calling them.
  Tween1.cancel = gc
    
  Make "Tween1", Tween1
