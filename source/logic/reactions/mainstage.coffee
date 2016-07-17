Take ["Action", "Reaction"],
(      Action ,  Reaction )->

  help = false
  settings = false
  
  update = ()->
    if help or settings
      Action "MainStage:Hide"
    else
      Action "MainStage:Show"
  
  Reaction "Help:Show", ()-> update help = true
  Reaction "Help:Hide", ()-> update help = false
  Reaction "Settings:Show", ()-> update settings = true
  Reaction "Settings:Hide", ()-> update settings = false
