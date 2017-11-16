Take ["Action", "Reaction", "Settings", "Storage"], (Action, Reaction, Settings, Storage)->
  
  # By explicitly checking for the string "false", we make the default (empty) case true
  enabled = if Storage("Labels") is "false" then false else true
  
  update = (active)->
    if active
      Action "Labels:Show"
      Storage "Labels", "true"
    else
      Action "Labels:Hide"
      Storage "Labels", "false"
  
  arrowsSwitch = Settings.addSetting "switch",
    name: "Labels"
    value: enabled
    update: update
  
  Take "AllReady", ()->
    update enabled
