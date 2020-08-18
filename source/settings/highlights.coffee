Take ["Action", "Settings"], (Action, Settings)->

  update = (active)->
    Action "Highlights:Set", active

  Settings.addSetting "Switch", 3,
    name: "Highlights"
    value: true
    update: update

  Take "AllReady", ()->
    update true
