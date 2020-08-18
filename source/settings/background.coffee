Take ["Action", "Ease", "Fullscreen", "Mode", "Settings", "Storage"], (Action, Ease, Fullscreen, Mode, Settings, Storage)->

  Make "Background", Background = (value)->
    if value?
      Action "Background:Set", value

    else if typeof Mode.background is "string"
      Action "Background:Set", Mode.background

    else if Mode.background is true

      init = +Storage "Background" if Mode.settings
      init = .7 if isNaN init

      apply = (v)->
        Storage "Background", v
        Action "Background:Lightness", Ease.linear v, 0, 1, 0.25, 1

      if Mode.background is true
        Settings.addSetting "Slider",
          name: "Background Color"
          value: init
          snaps: [.7]
          update: apply

      Take "SceneReady", ()-> apply init

    else if Fullscreen.active()
      Action "Background:Set", "white"

    else
      Action "Background:Set", "transparent"
