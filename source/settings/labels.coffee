Take ["Action", "Settings"], (Action, Settings)->

  update = (active)->
    if active
      Action "Labels:Show"
    else
      Action "Labels:Hide"

  arrowsSwitch = Settings.addSetting "switch",
    name: "Labels"
    value: true
    update: update

  Take "AllReady", ()->
    update true
