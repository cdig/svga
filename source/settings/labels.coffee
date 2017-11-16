Take ["Action", "Reaction", "Settings"], (Action, Reaction, Settings)->
  
  enabled = if window.top.localStorage["SVGA-Labels"] is "false" then false else true
  
  update = (active)->
    if active
      Action "Labels:Show"
      window.top.localStorage["SVGA-Labels"] = "true"
    else
      Action "Labels:Hide"
      window.top.localStorage["SVGA-Labels"] = "false"
  
  arrowsSwitch = Settings.addSetting "switch",
    name: "Labels"
    value: enabled
    update: update
  
  Take "AllReady", ()->
    update enabled
