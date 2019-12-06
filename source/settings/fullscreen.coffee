Take ["Action", "Settings", "SVG"], (Action, Settings, SVG)->

  isFullscreen = ()->
    document.fullscreenElement? or document.msFullscreenElement? or document.webkitFullscreenElement?

  Make "Fullscreen",
    active: isFullscreen

  # If we support fullscreen in this browser, add a switch for it
  if document.fullscreenEnabled or document.msFullScreenEnabled or document.webkitFullscreenEnabled

    # We can't use the ?() shorthand for these functions because that doesn't work in Safari (possibly elsewhere)
    enterFullscreen = ()->
      return SVG.svg.requestFullscreen() if SVG.svg.requestFullscreen?
      return SVG.svg.msRequestFullscreen() if SVG.svg.msRequestFullscreen?
      return SVG.svg.webkitRequestFullscreen() if SVG.svg.webkitRequestFullscreen?

    exitFullscreen = ()->
      return document.exitFullscreen() if document.exitFullscreen?
      return document.msExitFullscreen() if document.msExitFullscreen?
      return document.webkitExitFullscreen() if document.webkitExitFullscreen?


    # Whenever the fullscreen state changes, make sure the switch matches the new state
    updateSwitch = (e)->
      fullScreenSwitch.setValue isFullscreen()
    window.addEventListener "fullscreenchange", updateSwitch
    window.addEventListener "MSFullscreenChange", updateSwitch
    window.addEventListener "webkitfullscreenchange", updateSwitch


    # Whenever the switch state changes, update the fullscreen state to match
    switchChanged = (switchActive)->
      if switchActive is isFullscreen()
        # NOOP — the fullscreen state already matches the switch state
      else if switchActive
        enterFullscreen()
      else
        exitFullscreen()


    # Create the switch
    fullScreenSwitch = Settings.addSetting "switch",
      name: "Full Screen"
      value: false
      update: switchChanged
