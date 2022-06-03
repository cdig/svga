# scope.milliTick
# An every-frame update function that can be turned on and off by the content creator.
# The frame rate is capped to 1000 Hz but otherwise approximates display refresh rate.

Take ["Registry", "Tick"], (Registry, Tick)->
  Registry.add "ScopeProcessor", (scope)->
    return unless scope.milliTick?

    running = true
    acc = 0
    accTime = 0

    # Replace the actual scope milliTick function with a warning
    milliTick = scope.milliTick
    scope.milliTick = ()-> throw new Error "@milliTick() is called by the system. Please don't call it yourself."

    # Store a secret copy of the real milliTick function, so that warmup can use it
    scope._milliTick = milliTick

    Tick (time, dt)->
      return unless running
      acc += dt
      while acc > 1/1000
        acc -= 1/1000
        accTime += 1/1000
        milliTick.call scope, accTime, 1/1000

    scope.milliTick.start = ()->
      running = true

    scope.milliTick.stop = ()->
      running = false

    scope.milliTick.toggle = ()->
      if running then scope.milliTick.stop() else scope.milliTick.start()

    scope.milliTick.restart = ()->
      acc = 0
      accTime = 0
