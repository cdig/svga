Take ["Action", "Reaction", "Settings"], (Action, Reaction, Settings)->
  
  enabled = if window.top.localStorage["SVGA-FlowArrows"] is "false" then false else true
  
  update = (active)->
    if active
      Action "FlowArrows:Show"
      window.top.localStorage["SVGA-FlowArrows"] = "true"
    else
      Action "FlowArrows:Hide"
      window.top.localStorage["SVGA-FlowArrows"] = "false"
  
  arrowsSwitch = Settings.addSetting "switch",
    name: "Flow Arrows"
    value: enabled
    update: update
  
  Take "AllReady", ()->
    update enabled
