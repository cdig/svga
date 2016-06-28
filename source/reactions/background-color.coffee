Take ["Action", "Dispatch", "Global", "Reaction", "root"],
(      Action ,  Dispatch ,  Global ,  Reaction ,  root)->
  colors = ["#666", "#bbb", "#fff"]
  current = 1
  
  setColor = (index)->
    root.element.style["background-color"] = colors[index % colors.length]
  
  Reaction "setup", ()->
    setColor 1
  
  Reaction "cycleBackgroundColor", ()->
    setColor ++current
