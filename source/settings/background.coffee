Take ["Action", "Ease", "Mode", "Reaction", "Settings"], (Action, Ease, Mode, Reaction, Settings)->
  
  if typeof Mode.background is "string"
    Action "Background:Set", Mode.background
  
  else if Mode.background is true
    
    init = +window.top.localStorage["SVGA-Background"]
    init = .7 if isNaN init
    
    update = (v)->
      Action "Background:Lightness", v
      window.top.localStorage["SVGA-Background"] = v.toString()
    
    if Mode.background is true
      Settings.addSetting "slider",
        name: "Background"
        value: init
        snaps: [.7]
        update: (v)->
          update Ease.linear v, 0, 1, 0.25, 1
    
    Take "SceneReady", ()->
      update init

  else
    Action "Background:Set", "transparent"
