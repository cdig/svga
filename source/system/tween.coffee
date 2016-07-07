Take ["Ease", "RAF"], (Ease, RAF)->
  tweens = []
  
  
  Tween = (tween)->
    tween.from ?= cloneObj tween.on
    tween.delta = diffObj tween.to, tween.from
    tweens.push tween
    RAF update, true
  
  
  update = (t)->
    tweens = (updateTween tween, t/1000 for tween in tweens).filter (t)-> t?
    RAF update, true if tweens.length > 0
  
  updateTween = (tween, time)->
    tween.started ?= time
    pos = Math.min 1, (time - tween.started) / tween.time
    for k,v of tween.delta
      tween.on[k] = v * Ease.cubic(pos) + tween.from[k]
    tween.tick?()
    tween if pos < 1
  
  cloneObj = (obj)->
    out = {}
    out[k] = obj[k] for k,v of obj
    out
  
  diffObj = (a, b)->
    diff = {}
    diff[k] = a[k] - b[k] for k,v of a
    diff
  
  Make "Tween", Tween
