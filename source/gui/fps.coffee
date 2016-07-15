Take ["Config", "Resize", "SVG", "Tick", "TopBarReady"], (Config, Resize, SVG, Tick)->
  return unless Config "dev"
  
  count = 0
  freq = 1 # Update every n seconds
  avgLength = 10 # Average of the last 10 frames
  avgList = []
  total = 0
  text = SVG.create "text", SVG.root
  
  Resize ()->
    SVG.attrs text, x: 7, y: 68
  
  Tick (time, dt)->
    avgList.push 1/dt
    total += 1/dt
    total -= avgList.shift() if avgList.length > avgLength
    fps = Math.min 60, Math.ceil total/avgList.length
    if count++ / fps > freq
      count = 0
      SVG.attrs text, textContent: "FPS: " + fps
