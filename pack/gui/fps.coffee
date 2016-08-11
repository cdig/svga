Take ["Config", "Dev", "GUI", "Resize", "SVG", "Tick", "SVGReady"], (Config, Dev, GUI, Resize, SVG, Tick)->
  count = 60 # Update immediately
  freq = 1 # Update every n seconds
  avgLength = 10 # Average of the last 10 frames
  avgList = []
  total = 0
  fps = 0
  
  Make "FPS", ()-> fps
  
  if Dev
    text = SVG.create "text", GUI.elm, fill: "#666"

    Resize ()->
      if Config.nav
        SVG.attrs text, x: 10, y: 70
      else
        SVG.attrs text, x: 10, y: 25
  
  Tick (time, dt)->
    avgList.push 1/dt
    total += 1/dt
    total -= avgList.shift() if avgList.length > avgLength
    fps = Math.min 60, Math.ceil total/avgList.length
    
    if Dev and ++count / fps >= freq
      count = 0
      SVG.attrs text, textContent: "FPS: " + fps
