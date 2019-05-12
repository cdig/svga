Take ["Action", "Mode", "Reaction", "Settings", "Storage"], (Action, Mode, Reaction, Settings, Storage)->

  # By explicitly checking for the string "false", we make the default (empty) case true
  init = if Mode.settings and Storage("Highlights") is "false" then false else true

  update = (active)->
    Action "Highlights:Set", active
    Storage "Highlights", active

  Settings.addSetting "switch",
    name: "Highlights"
    value: init
    update: update

  Take "AllReady", ()->
    update init
