Take ["Config", "Dev", "GUI", "Resize", "SVG", "Tick", "SVGReady"], (Config, Dev, GUI, Resize, SVG, Tick)->
  count = 60 # Update immediately
  freq = 0.5 # Update every n seconds
  avgLength = 10 # Average of the last 10 frames
  avgList = []
  total = 0
  fps = 0
  
  Make "FPS", ()-> fps
  
  if Dev
    text = SVG.create "text", GUI.elm

    Resize ()->
      SVG.attrs text, x: 5, y: 20
  
  Tick (time, dt)->
    current = 1/dt
    
    # This needs to happen regardless of Dev, becasue other systems use FPS to turn on/off features for perf (eg: Highlight)
    if current > 20
      avgList.push 1/dt
      total += 1/dt
      total -= avgList.shift() if avgList.length > avgLength
      fps = Math.min 60, Math.ceil total/avgList.length
    else
      fps = Math.ceil current
    
    if Dev and ++count / fps >= freq
      count = 0
      SVG.attrs text, textContent: "FPS: " + fps, fill: if fps <= 5 then "#C00" else if fps <= 10 then "#E60" else "#777"
