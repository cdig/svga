Take ["Action", "Ease", "Mode", "Reaction", "Settings", "Storage"], (Action, Ease, Mode, Reaction, Settings, Storage)->
  
  if typeof Mode.background is "string"
    Action "Background:Set", Mode.background
  
  else if Mode.background is true
    
    init = +Storage "Background"
    init = .7 if isNaN init
    
    apply = (v)->
      Storage "Background", v
      Action "Background:Lightness", Ease.linear v, 0, 1, 0.25, 1
    
    if Mode.background is true
      Settings.addSetting "slider",
        name: "Background"
        value: init
        snaps: [.7]
        update: apply
    
    Take "SceneReady", ()-> apply init

  else
    Action "Background:Set", "transparent"
