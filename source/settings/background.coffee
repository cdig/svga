Take ["Action", "Ease", "Fullscreen", "Mode", "Settings", "Storage"], (Action, Ease, Fullscreen, Mode, Settings, Storage)->

  defaultLightness = .7
  lightness = defaultLightness


  applyLightness = ()->
    Action "Background:Lightness", Ease.linear lightness, 0, 1, 0.25, 1


  if Mode.background is true and Mode.settings
    lightness = +Storage "Background"
    lightness = defaultLightness if isNaN lightness

    Settings.addSetting "Slider", 1,
      name: "Background Color"
      value: lightness
      snaps: [defaultLightness]
      update: (v)->
        Storage "Background", lightness = v
        applyLightness()


  Background = ()->
    if typeof Mode.background is "string" # Use a specific color
      Action "Background:Set", Mode.background

    else if Mode.background is true # Use lightness-based background
      applyLightness()

    else if Fullscreen.active() # Default — fullscreen
      Action "Background:Set", "white"

    else # Default — windowed
      Action "Background:Set", "transparent"


  Make "Background", Background

  # Run after the scene is ready, to set the initial color for ManifoldBackground
  Take "SceneReady", Background
