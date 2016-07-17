# Tween
# Takes a `tween` object with the following props:
# on: (optional) an object that contains the values to be animated. Will be mutated each frame. Will be a clone of `from` if not provided.
# from: (optional) an object that contains the starting values. Will be a clone of `on` if not provided.
# to: (required) an object that contains the final values.
# time: (required) how long (seconds) should the tween take?
# tick: (optional) a function to be called each frame. Will be called with the current pos (0 to 1) and the `tween` object you passed in


Take ["RAF"], (RAF)->
  tweens = []
  
  Tween = (tween)->
    tween.on ?= cloneObj tween.from
    tween.from ?= cloneObj tween.on
    tween.delta = diffObj tween.to, tween.from
    tweens.push tween
    RAF update, true
    tween # Composable
  
  Tween.cancel = (tween)->
    tween?.cancelled = true
  
  update = (t)->
    tweens = (updateTween tween, t/1000 for tween in tweens).filter (t)-> t?
    RAF update, true if tweens.length > 0
  
  updateTween = (tween, time)->
    tween.started ?= time
    pos = Math.min 1, (time - tween.started) / tween.time
    for k,v of tween.delta
      tween.on[k] = v * cubic(pos) + tween.from[k]
    tween.tick?(pos, tween)
    tween if pos < 1 and not tween.cancelled
  
  cloneObj = (obj)->
    out = {}
    out[k] = obj[k] for k,v of obj
    out
  
  diffObj = (a, b)->
    diff = {}
    diff[k] = a[k] - b[k] for k,v of a
    diff
  
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
    
  
  Make "Tween", Tween
