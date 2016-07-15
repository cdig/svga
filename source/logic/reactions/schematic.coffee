Take ["Action", "Dispatch", "Reaction", "root"],
(      Action ,  Dispatch ,  Reaction ,  root)->
  
  animateMode = false
  
  Reaction "ScopeReady", ()->
    Action "Schematic:Show"
  
  Reaction "Schematic:Toggle", ()->
    Action if animateMode then "Schematic:Show" else "Schematic:Hide"
  
  Reaction "Schematic:Hide", ()->
    animateMode = true
    Dispatch root, "animateMode"
  
  Reaction "Schematic:Show", ()->
    animateMode = false
    Dispatch root, "schematicMode"
