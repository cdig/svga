# scope.rawTick
# An every-frame update function that can be turned on and off by the content creator.
# The frame rate is uncapped, and will run at the native refresh rate in supporting browsers.

Take ["Registry", "Tick"], (Registry, Tick)->

  speed = 1

  Registry.add "ScopeProcessor", (scope)->
    return unless scope.rawTick?

    running = true
    accTime = 0
    step = 0

    # Replace the actual scope rawTick function with a warning
    rawTick = scope.rawTick
    scope.rawTick = ()-> throw new Error "@rawTick() is called by the system. Please don't call it yourself."

    scope.rawTick.start = ()->
      running = true

    scope.rawTick.stop = ()->
      running = false

    scope.rawTick.toggle = ()->
      if running then scope.rawTick.stop() else scope.rawTick.start()

    scope.rawTick.restart = ()->
      accTime = 0

    scope.rawTick.speed = (s)->
      speed = s if s?
      speed

    scope.rawTick.step = ()->
      accTime += step
      rawTick.call scope, accTime, step

    # Store a secret copy of the real rawTick function, so that warmup can use it
    scope._rawTick = (time, dt)->
      return unless running
      step = dt * speed
      scope.rawTick.step()

    Tick scope._rawTick
