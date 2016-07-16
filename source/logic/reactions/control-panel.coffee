Take ["Action", "Reaction"],
(      Action ,  Reaction )->

  schematic = false
  settings = false
  
  updateShowing = ()->
    if schematic or settings
      Action "ControlPanel:Hide"
    else
      Action "ControlPanel:Show"

  Reaction "Schematic:Show", ()-> updateShowing  schematic = true
  Reaction "Schematic:Hide", ()-> updateShowing schematic = false
  Reaction "Settings:Show", ()-> updateShowing  settings = true
  Reaction "Settings:Hide", ()-> updateShowing settings = false
