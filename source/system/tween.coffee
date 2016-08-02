# Tween
# This is a half-decent value interpolator.
# Note: If you are super good with CoffeeScript precedence rules, turn back now!

Take ["Tick"], (Tick)->
  tweens = []
  skipGC = false
  
  Tween = (from, to, time, tween)->
    
    # The 4th arg can be a tick function or an options object
    tween = {tick: tween} if typeof tween is "function"
    
    # from/to can be numbers or objects. Internally, we'll work with objects.
    tween.multi = typeof from is "object"
    
    # If you don't provide a tick function, we'll assume we're mutating the from object.
    tween.mutate ?= not tween.tick?
    
    tween.keys = keys = if tween.multi then getKeys from, to else ["v"]
    tween.from = if tween.multi then clone from, keys else {v:from}
    tween.to = if tween.multi then clone to, keys else {v:to}
    tween.delta = dist tween.from, tween.to, keys
    tween.value = if tween.mutate and tween.multi then from else clone tween.from, keys
    tween.time = Math.max 0, time
    tween.ease = getEaseFn tween.ease
    tween.pos = Math.min 1, tween.pos or 0
    tween.cancelled = false
    
    # Now is a great time to do some GC
    gc tween.tick, tween.from
    
    tweens.push tween
    tween # Composable

  
  getKeys = (a, b)->
    # Returns an array of keys used by both a and b
    k for k of a when b[k]?
  
  
  clone = (i, keys)->
    o = {}
    o[key] = i[k] for key in keys
    o
    
  
  dist = (from, to, keys)->
    o = {}
    o[k] = to[k] - from[k] for k in keys
    o
  
  
  getEaseFn = (given)->
    if typeof given is "string"
      eases[given] or throw "Tween: \"#{given}\" is not a value ease type."
    else if typeof given is "function"
      given
    else
      eases.cubic
    
  
  eases =
    linear: (v)-> v
    
    cubic: (input)->
      input = 2 * Math.min 1, Math.abs input
      if input < 1
        0.5 * Math.pow input, 3
      else
        1 - 0.5 * Math.abs Math.pow input-2, 3
  
  
  gc = (tick, from)->
    return if skipGC # Don't GC if we're in the middle of a tick!
    tweens = tweens.filter (tween)->
      return false if tween.pos >= 1
      return false if tween.cancelled
      return false if tick? and tick is tween.tick # this makes interruptions work normally
      return false if from? and from is tween.from # this makes interruptions work with mutate
      return true
  
  
  Tween.cancel = (tweensToCancel...)->
    tween.cancelled = true for tween in tweensToCancel
    gc() # Aww sure, let's do a GC!
  
  
  # WE MIGHT NOT NEED THIS NOW THAT WE HAVE MUTATE
  # Anima is a nice way to create a stateful animation that stores its state internally
  # Tween.anima = (from, opts)->
  #   tick = if typeof opts is "function" then opts else opts.tick
  #   opts.tick = (value)-> tick? from = value
  #   return (to, time = 0)-> # This is the "anima"
  #     return Tween from, to, time, opts # This is the "animatween"
  
  
  Tick (t, dt)->
    skipGC = true # It's probably not safe to GC in the middle of our tick loop
    for tween in tweens when not tween.cancelled
      if tween.pos < 1
        tween.pos = Math.min 1, tween.pos + dt / tween.time
        e = tween.ease tween.pos
        for k in tween.keys
          tween.value[k] = tween.from[k] + tween.delta[k] * e
        v = if tween.multi then tween.value else tween.value.v
        tween.tick v, tween
      else
        v = if tween.multi then tween.value else tween.value.v
        tween.then? v, tween
    # Hey, another great time to do some GC!
    skipGC = false
    gc()
    
  
  Make "Tween", Tween
