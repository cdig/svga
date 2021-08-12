Take ["Config", "Registry", "ScopeCheck"], (Config, Registry, ScopeCheck)->

  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "initialWidth", "initialHeight"

    # In Chrome, calculating the BBox takes something like 16ms per element (as of v92, at least).
    # But we don't ever really use the initial size, so we're moving this feature behind a flag.
    # If you need it, enable it via config, but do me a favor: Do a performance profile,
    # and look for excess time spent inside the buildScopes function (from source/core/scene.coffee)
    # during the initial load. Don't ship something that has a huge pause at init time.

    if Config.enableInitialSize
      size = scope.element.getBBox()
      scope.initialWidth = size.width
      scope.initialHeight = size.height
