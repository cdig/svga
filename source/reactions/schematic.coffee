Take ["Action", "Reaction"], (Action, Reaction)->
  schematicMode = true
  
  Reaction "Schematic:Hide", ()-> schematicMode = false
  Reaction "Schematic:Show", ()-> schematicMode = true
  
  Reaction "Schematic:Toggle", ()->
    Action if schematicMode then "Schematic:Hide" else "Schematic:Show"
  
  Take "AllReady", ()->
    Action "Schematic:Hide"
