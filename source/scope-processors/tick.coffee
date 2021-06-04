# scope.tick
# An every-frame update function that can be turned on and off by the content creator.
# The frame rate is capped to 60 Hz.

Take ["Registry", "Tick"], (Registry, Tick)->
  Registry.add "ScopeProcessor", (scope)->
    return unless scope.tick?

    running = true
    acc = 0
    accTime = 0

    # Replace the actual scope tick function with a warning
    tick = scope.tick
    scope.tick = ()-> throw new Error "@tick() is called by the system. Please don't call it yourself."

    # Store a secret copy of the real tick function, so that warmup can use it
    scope._tick = tick

    Tick (time, dt)->
      return unless running
      acc += dt
      while acc > 1/60
        acc -= 1/60
        accTime += 1/60
        tick.call scope, accTime, 1/60

    scope.tick.start = ()->
      running = true

    scope.tick.stop = ()->
      running = false

    scope.tick.toggle = ()->
      if running then scope.tick.stop() else scope.tick.start()

    scope.tick.restart = ()->
      startTime = null
