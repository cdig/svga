Take ["Action", "Reaction"], (Action, Reaction)->
  root = true
  schematic = false
  
  update = ()->
    if root and not schematic
      Action "ControlPanel:Show"
    else
      Action "ControlPanel:Hide"
  
  Reaction "Schematic:Hide", ()-> update schematic = false
  Reaction "Schematic:Show", ()-> update schematic = true
  Reaction "Root:Hide", ()-> update root = false
  Reaction "Root:Show", ()-> update root = true
