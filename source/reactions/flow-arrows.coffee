Take ["Action", "Reaction"], (Action, Reaction)->
  showing = false
  
  Reaction "FlowArrows:Hide", ()-> showing = false
  Reaction "FlowArrows:Show", ()-> showing = true
  
  Reaction "FlowArrows:Toggle", ()->
    Action if showing then "FlowArrows:Hide" else "FlowArrows:Show"

  Take "AllReady", ()->
    Action "FlowArrows:Show"
