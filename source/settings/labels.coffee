Take ["Action", "Settings"], (Action, Settings)->

  update = (active)->
    if active
      Action "Labels:Show"
    else
      Action "Labels:Hide"

  Settings.addSetting "Switch", 4,
    name: "Labels"
    value: true
    update: update

  Take "AllReady", ()->
    update true
