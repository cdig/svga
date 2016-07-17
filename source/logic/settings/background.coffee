Take ["Action", "Dispatch", "Reaction", "DOMContentLoaded"],
(      Action ,  Dispatch ,  Reaction)->
  
  setBackground = (v)->
    c = "hsl(220, 4%, #{v*100}%)"
    document.rootElement.style.backgroundColor = c
  
  Reaction "Background:Set", setBackground
  
  Reaction "GUIReady", ()->
    Action "Background:Set", .75
