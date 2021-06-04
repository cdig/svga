# scope.rawTick
# An every-frame update function.
# The frame rate is uncapped, and will run at the native refresh rate in supporting browsers.

Take ["Registry", "Tick"], (Registry, Tick)->
  Registry.add "ScopeProcessor", (scope)->
    return unless scope.rawTick?

    startTime = null

    # Replace the actual scope rawTick function with a warning
    rawTick = scope.rawTick
    scope.rawTick = ()-> throw new Error "@rawTick() is called by the system. Please don't call it yourself."

    # Store a secret copy of the real rawTick function, so that warmup can use it
    scope._rawTick = rawTick

    Tick (time, dt)->
      startTime ?= time
      rawTick.call scope, time - startTime, dt
