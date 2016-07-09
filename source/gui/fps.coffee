Take ["Resize", "SVG", "Tick", "TopBarReady"], (Resize, SVG, Tick)->
  
  avgLength = 120
  avgList = []
  total = 0
  text = SVG.create "text", SVG.root, fill: "#FFF"
  
  Resize ()->
    SVG.attrs text, x: window.innerWidth - 65, y: 30
  
  Tick (time, dt)->
    avgList.push 1/dt
    total += 1/dt
    total -= avgList.shift() if avgList.length > avgLength
    SVG.attrs text, textContent: "FPS: " + Math.min 60, Math.round total/avgList.length
