Take ["Action", "Mode", "Reaction", "Settings"], (Action, Mode, Reaction, Settings)->
  
  if typeof Mode.background is "string"
    Action "Background:Set", Mode.background
  
  else if Mode.background is true
    
    init = +window.localStorage["SVGA-Background"]
    init = .7 if isNaN init
    
    update = (v)->
      Action "Background:Lightness", v
      window.localStorage["SVGA-Background"] = v.toString()
    
    if Mode.background is true
      Settings.addSetting "slider",
        name: "Background"
        value: init
        snaps: [.7]
        update: update
    
    Take "SceneReady", ()->
      update init

  else
    Action "Background:Set", "transparent"
