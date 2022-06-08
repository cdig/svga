Take ["Tick", "SVGReady"], (Tick)->
  avgWindow = 1 # average over the past n seconds
  avgList = []
  total = 0
  fps = 1

  Make "FPS", ()-> fps

  Tick (time, dt)->
    avgList.push dt
    total += dt
    total -= avgList.shift() while total > avgWindow and avgList.length > 0
    fps = avgList.length/total # will be artifically low for the first second — that's fine
    fps = 2 if isNaN fps # If we drop too low we get NaN — cap to 2
