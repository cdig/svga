# Tween1
# This is just a really dumb value interpolator

Take ["Ease", "Tick"], (Ease, Tick)->
  tweens = []
  
  Tween1 = (from, to, time, tick, next)->
    
    gc tick # Now is a great time to do some GC
    
    tweens = tweens.filter (tween)->
      return false if tween.pos >= 1
      return false if tween.cancelled
      return false if tween.tick is tick
      return false if tween is next
      return true
    
    tweens.push tween =
      from: from
      to: to
      time: time
      tick: tick
      cancelled: false
      pos: 0
      value: from
      delta: to - from
      next: next
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
  
  gc = (ticks...)->
    tweens = tweens.filter (tween)->
      return false if tween.pos >= 1
      return false if tween.cancelled
      return false if tween.tick in ticks
      return true
  
  
  # You can pass as many callbacks as you want to this. We'll stop calling them.
  Tween1.cancel = gc
    
  Make "Tween1", Tween1
