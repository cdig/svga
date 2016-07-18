Take ["Action", "Reaction", "DOMContentLoaded"], (Action, Reaction)->
  
  setBackground = (v)->
    c = "hsl(220, 5%, #{v*100}%)"
    document.rootElement.style.backgroundColor = c
  
  Reaction "Background:Set", setBackground
  
  Take "GUIReady", ()->
    Action "Background:Set", .75
