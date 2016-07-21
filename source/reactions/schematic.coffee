Take ["Action", "Reaction"], (Action, Reaction)->
  animateMode = false
  
  Take "ScopeReady", ()->
    Action "Schematic:Hide" # TODO: Debuggin
  
  Reaction "Schematic:Toggle", ()->
    Action if animateMode then "Schematic:Show" else "Schematic:Hide"
  
  Reaction "Schematic:Hide", ()->
    animateMode = true
  
  Reaction "Schematic:Show", ()->
    animateMode = false
