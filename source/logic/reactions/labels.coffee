Take ["Action", "Reaction", "root"],
(      Action ,  Reaction ,  root)->
  
  showing = false
  
  Reaction "Labels:Hide", ()-> showing = false
  Reaction "Labels:Show", ()-> showing = true
  
  Reaction "Labels:Toggle", ()->
    Action if showing then "Labels:Hide" else "Labels:Show"
