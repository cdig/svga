Take ["Action", "Reaction"], (Action, Reaction)->
  showing = true
  
  Reaction "FlowArrows:Hide", ()-> showing = false
  Reaction "FlowArrows:Show", ()-> showing = true
  
  Reaction "FlowArrows:Toggle", ()->
    Action if showing then "FlowArrows:Hide" else "FlowArrows:Show"
  
  # TODO: Is this necessary? Isn't this the default?
  Take "AllReady", ()->
    Action "FlowArrows:Show"
