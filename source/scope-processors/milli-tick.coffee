# scope.milliTick
# An every-frame update function that can be turned on and off by the content creator.
# The frame rate is capped to 1000 Hz but otherwise approximates display refresh rate.

Take ["Registry", "Tick"], (Registry, Tick)->

  speed = 1

  Registry.add "ScopeProcessor", (scope)->
    return unless scope.milliTick?

    running = true
    acc = 0
    accTime = 0
    step = 1/1000

    # Replace the actual scope milliTick function with a warning
    milliTick = scope.milliTick
    scope.milliTick = ()-> throw new Error "@milliTick() is called by the system. Please don't call it yourself."

    # Store a secret copy of the real milliTick function, so that warmup can use it
    scope._milliTick = milliTick

    Tick (time, dt)->
      return unless running
      acc += dt * speed
      while acc > step
        acc -= step
        accTime += step
        milliTick.call scope, accTime, step

    scope.milliTick.start = ()->
      running = true

    scope.milliTick.stop = ()->
      running = false

    scope.milliTick.toggle = ()->
      if running then scope.milliTick.stop() else scope.milliTick.start()

    scope.milliTick.restart = ()->
      acc = 0
      accTime = 0

    scope.milliTick.speed = (s)->
      speed = s
