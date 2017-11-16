Take ["Action", "Reaction", "Settings", "Storage"], (Action, Reaction, Settings, Storage)->
  
  # By explicitly checking for the string "false", we make the default (empty) case true
  enabled = if Storage("FlowArrows") is "false" then false else true
  
  update = (active)->
    if active
      Action "FlowArrows:Show"
      Storage "FlowArrows", "true"
    else
      Action "FlowArrows:Hide"
      Storage "FlowArrows", "false"
  
  arrowsSwitch = Settings.addSetting "switch",
    name: "Flow Arrows"
    value: enabled
    update: update
  
  Take "AllReady", ()->
    update enabled
