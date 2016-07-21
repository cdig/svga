Take ["Action", "Reaction"],
(      Action ,  Reaction )->

  animate = false
  mainStage = true
  
  update = ()->
    if animate and mainStage
      Action "ControlPanel:Show"
    else
      Action "ControlPanel:Hide"
  
  Reaction "Schematic:Show", ()-> update animate = false
  Reaction "Schematic:Hide", ()-> update animate = true
  Reaction "Root:Show", ()-> update mainStage = true
  Reaction "Root:Hide", ()-> update mainStage = false
