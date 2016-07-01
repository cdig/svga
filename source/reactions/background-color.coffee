Take ["Action", "Dispatch", "Reaction", "SVGReady"],
(      Action ,  Dispatch ,  Reaction)->
  colors = ["#666", "#bbb", "#fff"]
  current = 1
  
  setColor = (index)->
    document.rootElement.style["background-color"] = colors[index % colors.length]
  
  Reaction "setup", ()->
    setColor 1
  
  Reaction "cycleBackgroundColor", ()->
    setColor ++current
