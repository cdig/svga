Take ["Action", "Dispatch", "Reaction"], (Action, Dispatch, Reaction)->
  animateMode = false
  
  Take "ScopeReady", ()->
    Action "Schematic:Hide" # TODO: Debuggin
  
  Reaction "Schematic:Toggle", ()->
    Action if animateMode then "Schematic:Show" else "Schematic:Hide"
  
  Reaction "Schematic:Hide", ()->
    animateMode = true
    Dispatch "animateMode"
  
  Reaction "Schematic:Show", ()->
    animateMode = false
    Dispatch "schematicMode"
