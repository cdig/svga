Take ["GUI", "Mode", "ParentElement", "SVG", "Tick", "SVGReady"], (GUI, Mode, ParentElement, SVG, Tick)->
  freq = .2 # Update every n seconds
  count = freq # Update immediately
  avgWindow = 1 # average over the past n seconds
  avgList = []
  total = 0
  fps = 1
  text = null
  nodeCountText = ""
  
  Make "FPS", ()-> fps
  
  if Mode.dev
    
    nodeCountElm = document.querySelector "[node-count]"
    if nodeCountElm?
      nodeCountText = nodeCountElm.getAttribute("node-count") + " nodes<br>"
    
    text = document.createElement "div"
    text.setAttribute "svga-fps", "true"
    if ParentElement is document.body
      document.body.insertBefore text, document.body.firstChild
    else
      # If the SVGA is removed and re-added, it creates duplicate FPS text elements.
      # So if there's an existing element, we should just use it.
      prev = ParentElement.previousSibling
      if prev?.hasAttribute? "svga-fps"
        text = prev
      else
        ParentElement.parentNode?.insertBefore text, ParentElement

  Tick (time, dt)->
    # This needs to happen regardless of Mode.dev, becasue other systems use FPS to turn on/off features for perf (eg: Highlight)
    
    avgList.push dt
    total += dt
    total -= avgList.shift() while total > avgWindow and avgList.length > 0
    fps = avgList.length/total # will be artifically low for the first second — that's fine
    fps = Math.min 60, fps # our method is slightly inexact, so sometimes you get numbers over 60 — cap to 60
    fps = 2 if isNaN fps # If we drop too low we get NaN — cap to 2
    
    count += dt
    if Mode.dev and count >= freq
      count -= freq
      fpsDisplay = if fps < 30 then fps.toFixed(1) else Math.ceil(fps)
      text.innerHTML = nodeCountText + fpsDisplay + " fps"
      text.style.color = if fps <= 5 then "#C00" else if fps <= 10 then "#E60" else "rgba(0,0,0,0.1)"
