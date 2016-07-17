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
  Reaction "MainStage:Show", ()-> update mainStage = true
  Reaction "MainStage:Hide", ()-> update mainStage = false
