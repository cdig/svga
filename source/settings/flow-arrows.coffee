Take ["Action", "Settings"], (Action, Settings)->

  update = (active)->
    if active
      Action "FlowArrows:Show"
    else
      Action "FlowArrows:Hide"

  Settings.addSetting "Switch", 2,
    name: "Flow Arrows"
    value: true
    update: update

  Take "AllReady", ()->
    update true
