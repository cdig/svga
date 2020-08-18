Take ["Action", "Settings", "SVG"], (Action, Settings, SVG)->

  # Break circular dependency
  Background = null
  Take "Background", (b)-> Background = b

  isFullscreen = ()->
    document.fullscreenElement? or document.webkitFullscreenElement?

  Make "Fullscreen",
    active: isFullscreen

  # If we support fullscreen in this browser, add a switch for it
  if document.fullscreenEnabled or document.webkitFullscreenEnabled

    # We can't use the ?() shorthand for these functions because that doesn't work in Safari (possibly elsewhere)
    enterFullscreen = ()->
      return SVG.svg.requestFullscreen() if SVG.svg.requestFullscreen?
      return SVG.svg.webkitRequestFullscreen() if SVG.svg.webkitRequestFullscreen?

    exitFullscreen = ()->
      return document.exitFullscreen() if document.exitFullscreen?
      return document.webkitExitFullscreen() if document.webkitExitFullscreen?


    update = (e)->
      # Make sure the switch matches the new state
      fullScreenSwitch.setValue isFullscreen()

      # Update background color
      Background?()

    window.addEventListener "fullscreenchange", update
    window.addEventListener "webkitfullscreenchange", update


    # Whenever the switch state changes, update the fullscreen state to match
    switchChanged = (switchActive)->
      if switchActive is isFullscreen()
        # NOOP — the fullscreen state already matches the switch state
      else if switchActive
        enterFullscreen()
      else
        exitFullscreen()


    # Create the switch
    fullScreenSwitch = Settings.addSetting "Switch", 5,
      name: "Full Screen"
      value: false
      update: switchChanged
