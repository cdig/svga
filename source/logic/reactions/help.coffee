Take ["Action","Reaction","root"],
(      Action , Reaction , root)->
  showing = false
  
  Reaction "Help:Toggle", ()->
    Action if showing then "Help:Hide" else "Help:Show"
  
  Reaction "Help:Hide", ()-> showing = false
  Reaction "Help:Show", ()-> showing = true
  Reaction "Settings:Show", ()-> Action "Help:Hide"
