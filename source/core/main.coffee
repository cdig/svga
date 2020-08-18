Take ["Registry", "Scene", "SVG", "ParentData"], (Registry, Scene, SVG)->
  # We don't use ParentData, but we need it to exist before we can safely continue

  # This is the very first code that changes the DOM. It crawls the entire DOM and:
  # 1. Makes structural changes to prepare things for animation.
  # 2. Returns a tree of DOM references that we'll link Symbols to.
  svgData = Scene.crawl SVG.root

  # We're done the initial traversal of the SVG. It's now safe for systems to mutate it.
  Make "SVGReady"

  # We need to wait a bit for ScopeProcessors
  setTimeout ()->

    # By now, we're assuming all ScopeProcessors are ready.
    Registry.closeRegistration "ScopeProcessor"

    # Inform all systems that it's now safe to use Scope.
    Make "ScopeReady"

    # By now, we're assuming all Controls are ready.
    Registry.closeRegistration "Control"

    # Inform all systems that we've just finished setting up Controls.
    Make "ControlReady"

    # We need to wait a bit for Symbols
    setTimeout ()->

      # By now, we're assuming all Symbols are ready.
      Registry.closeRegistration "Symbols"
      Registry.closeRegistration "SymbolNames"

      # Use the DOM references collected earlier to build our Scene tree.
      Scene.build svgData
      svgData = null # Free this memory

      # We also need to wait until we're properly displayed on screen.
      checkBounds()


  checkBounds = ()->

    # If we don't do this check, we can get divide by zero errors in Nav.
    # The root bounds will be zero if the export from Flash was bad, or if this SVGA is loaded in Chrome with display: none.
    initialRootRect = SVG.root.getBoundingClientRect()
    if initialRootRect.width < 1 or initialRootRect.height < 1
      setTimeout checkBounds, 500 # Keep re-checking until whatever loaded this SVGA is ready to display it.

    else

      # Inform all systems that we've just finished setting up the scene.
      Make "SceneReady"

      # Inform all systems that bloody everything is done.
      Make "AllReady"
