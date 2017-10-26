Take ["Action", "Reaction"], (Action, Reaction)->
  help = false
  settings = false
  
  update = ()->
    if help or settings
      Action "Root:Hide"
    else
      Action "Root:Show"
  
  Reaction "Settings:Show", ()-> update settings = true
  Reaction "Settings:Hide", ()-> update settings = false
