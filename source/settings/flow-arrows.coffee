Take ["Action", "Settings"], (Action, Settings)->

  update = (active)->
    if active
      Action "FlowArrows:Show"
    else
      Action "FlowArrows:Hide"

  arrowsSwitch = Settings.addSetting "Switch",
    name: "Flow Arrows"
    value: true
    update: update

  Take "AllReady", ()->
    update true
