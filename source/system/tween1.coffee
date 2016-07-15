# Tween1
# This is just a really dumb value interpolator

Take ["Ease", "Tick"], (Ease, Tick)->
  tweens = []
  
  Tween1 = (args..., tick)->
    from = args[0] or 0
    to   = args[1] or 1
    time = args[2] or 1
    
    gc tick # Now is a great time to do some GC
    
    tweens = tweens.filter (tween)->
      return false if tween.pos >= 1
      return false if tween.cancelled
      return false if tween.tick is tick
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
    tween # Composable
  
  Tick (t, dt)->
    for tween in tweens when tween.pos < 1 and not tween.cancelled
      tween.pos += dt / tween.time
      tween.value = tween.from + tween.delta * Ease.cubic Math.min 1, tween.pos
      tween.tick tween.value, tween
  
  gc = (ticks...)->
    tweens = tweens.filter (tween)->
      return false if tween.pos >= 1
      return false if tween.cancelled
      return false if tween.tick in ticks
      return true
  
  
  # You can pass as many callbacks as you want to this. We'll stop calling them.
  Tween1.cancel = gc
    
  Make "Tween1", Tween1
