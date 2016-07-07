Take ["Action","Reaction","root"],
(      Action , Reaction , root)->
  showing = false
  
  Reaction "ScopeReady", ()->
    Action "FlowArrows:Show"
  
  Reaction "FlowArrows:Toggle", ()->
    Action if showing then "FlowArrows:Show" else "FlowArrows:Hide"
  
  Reaction "FlowArrows:Hide", ()->
    showing = true
  
  Reaction "FlowArrows:Show", ()->
    showing = false
