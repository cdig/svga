Take ["Action", "Reaction"], (Action, Reaction)->
  showing = false
  
  Reaction "Settings:Hide", ()-> showing = false
  Reaction "Settings:Show", ()-> showing = true
  
  Reaction "Settings:Toggle", ()->
    Action if showing then "Settings:Hide" else "Settings:Show"
  
  Reaction "Help:Show", ()->
    Action "Settings:Hide"
