Take ["Action", "Settings"], (Action, Settings)->

  update = (active)->
    Action "Highlights:Set", active

  Settings.addSetting "switch",
    name: "Highlights"
    value: true
    update: update

  Take "AllReady", ()->
    update true
