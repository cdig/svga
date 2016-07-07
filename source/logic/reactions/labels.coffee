Take ["Action", "Reaction", "root"],
(      Action ,  Reaction ,  root)->
  
  return unless labels = root.mainStage?.labelsContainer
  
  Reaction "Labels:Hide", ()->
    labels.visible = false
  
  Reaction "Labels:Show", ()->
    labels.visible = true
    
  Reaction "Labels:Toggle", ()->
    Action if labels.visible then "Labels:Hide" else "Labels:Show"
