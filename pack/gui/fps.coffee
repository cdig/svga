Take ["GUI", "Mode", "ParentObject", "Resize", "SVG", "Tick", "SVGReady"], (GUI, Mode, ParentObject, Resize, SVG, Tick)->
  freq = .2 # Update every n seconds
  count = freq # Update immediately
  avgWindow = 1 # average over the past n seconds
  avgList = []
  total = 0
  fps = 1
  text = null
  
  Make "FPS", ()-> fps
  
  if Mode.dev
    text = document.createElement "div"
    text.setAttribute "svga-fps", "true"
    if ParentObject is document.body
      document.body.insertBefore text, document.body.firstChild
    else
      ParentObject.parentNode?.insertBefore text, ParentObject

  Tick (time, dt)->
    # This needs to happen regardless of Mode.dev, becasue other systems use FPS to turn on/off features for perf (eg: Highlight)
    
    avgList.push dt
    total += dt
    total -= avgList.shift() while total > avgWindow and avgList.length > 0
    fps = avgList.length/total # will be artifically low for the first second — that's fine
    fps = 2 if isNaN fps # If we drop too low we get NaN — cap to 2
    
    count += dt
    if Mode.dev and count >= freq
      count -= freq
      fpsDisplay = if fps < 10 then fps.toFixed(1) else Math.ceil(fps)
      text.textContent = fpsDisplay
      text.style.color = if fps <= 5 then "#C00" else if fps <= 10 then "#E60" else "rgba(0,0,0,0.5)"
