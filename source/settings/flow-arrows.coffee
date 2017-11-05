Take ["Action", "Reaction", "Settings"], (Action, Reaction, Settings)->
  
  enabled = if window.localStorage["SVGA-FlowArrows"] is "false" then false else true
  
  update = (active)->
    if active
      Action "FlowArrows:Show"
      window.localStorage["SVGA-FlowArrows"] = "true"
    else
      Action "FlowArrows:Hide"
      window.localStorage["SVGA-FlowArrows"] = "false"
  
  arrowsSwitch = Settings.addSetting "switch",
    name: "Flow Arrows"
    value: enabled
    update: update
  
  Take "AllReady", ()->
    update enabled
