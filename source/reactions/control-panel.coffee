Take ["Action", "ControlPanel", "Reaction"], (Action, ControlPanel, Reaction)->
  root = true
  schematic = false
  
  Reaction "ControlPanel:Hide", ControlPanel.hide
  Reaction "ControlPanel:Hide", ControlPanel.show
  
  update = ()->
    if root and not schematic
      Action "ControlPanel:Show"
    else
      Action "ControlPanel:Hide"
  
  Reaction "Schematic:Hide", ()-> update schematic = false
  Reaction "Schematic:Show", ()-> update schematic = true
  Reaction "Root:Hide", ()-> update root = false
  Reaction "Root:Show", ()-> update root = true
