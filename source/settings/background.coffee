Take ["Action", "Reaction", "Settings"], (Action, Reaction, Settings)->
  
  init = +window.localStorage["SVGA-Background"]
  init = .7 if isNaN init
  
  update = (v)->
    Action "Background:Lightness", v
    window.localStorage["SVGA-Background"] = v.toString()
  
  Settings.addSetting "slider",
    name: "Background"
    value: init
    snaps: [.7]
    update: update
  
  Take "AllReady", ()->
    update init
