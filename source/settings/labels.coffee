Take ["Action", "Reaction", "Settings"], (Action, Reaction, Settings)->
  
  enabled = if window.localStorage["SVGA-Labels"] is "false" then false else true
  
  update = (active)->
    if active
      Action "Labels:Show"
      window.localStorage["SVGA-Labels"] = "true"
    else
      Action "Labels:Hide"
      window.localStorage["SVGA-Labels"] = "false"
  
  arrowsSwitch = Settings.addSetting "switch",
    name: "Labels"
    value: enabled
    update: update
  
  Take "AllReady", ()->
    update enabled
