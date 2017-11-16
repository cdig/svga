Take ["Action", "Reaction", "Settings", "Storage"], (Action, Reaction, Settings, Storage)->
  
  # By explicitly checking for the string "false", we make the default (empty) case true
  init = if Storage("Highlights") is "false" then false else true
  
  update = (active)->
    Action "Highlights:Set", active
    Storage "Highlights", active
  
  Settings.addSetting "switch",
    name: "Highlights"
    value: init
    update: update
  
  Take "AllReady", ()->
    update init
