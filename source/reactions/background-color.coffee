Take ["Action", "Dispatch", "Global", "Reaction", "SVGReady"],
(      Action ,  Dispatch ,  Global ,  Reaction)->
  colors = ["#666", "#bbb", "#fff"]
  current = 1
  
  setColor = (index)->
    document.rootElement.style["background-color"] = colors[index % colors.length]
  
  Reaction "setup", ()->
    setColor 1
  
  Reaction "cycleBackgroundColor", ()->
    setColor ++current
