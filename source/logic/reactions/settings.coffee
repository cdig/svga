Take ["Action","Reaction","root"],
(      Action , Reaction , root)->
  showing = false
  
  Reaction "Settings:Toggle", ()->
    Action if showing then "Settings:Hide" else "Settings:Show"
  
  Reaction "Settings:Hide", ()->
    showing = false
  
  Reaction "Settings:Show", ()->
    showing = true