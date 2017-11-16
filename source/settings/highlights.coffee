Take ["Action", "Reaction", "Settings"], (Action, Reaction, Settings)->
  
  init = if window.top.localStorage["SVGA-Highlights"] is "false" then false else true
  
  update = (active)->
    Action "Highlights:Set", active
    window.top.localStorage["SVGA-Highlights"] = active.toString()
  
  Settings.addSetting "switch",
    name: "Highlights"
    value: init
    update: update
  
  Take "AllReady", ()->
    update init
