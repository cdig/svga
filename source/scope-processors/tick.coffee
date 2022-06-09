# scope.tick
# An every-frame update function that can be turned on and off by the content creator.
# The frame rate is capped to 60 Hz but otherwise approximates display refresh rate.

Take ["Registry", "Tick"], (Registry, Tick)->

  speed = 1

  Registry.add "ScopeProcessor", (scope)->
    return unless scope.tick?

    running = true
    acc = 0
    count = 0
    step = 1/60

    # Replace the actual scope tick function with a warning
    tick = scope.tick
    scope.tick = ()-> throw new Error "@tick() is called by the system. Please don't call it yourself."

    scope.tick.start = ()->
      running = true

    scope.tick.stop = ()->
      running = false

    scope.tick.toggle = ()->
      if running then scope.tick.stop() else scope.tick.start()

    scope.tick.restart = ()->
      acc = 0
      count = 0

    scope.tick.speed = (s)->
      speed = s if s?
      speed

    scope.tick.step = ()->
      count++
      tick.call scope, count * step, step

    # Store a secret copy of the real tick function, so that warmup can use it
    scope._tick = (time, dt)->
      return unless running
      acc += dt * speed
      while acc > step
        acc -= step
        scope.tick.step()

    Tick scope._tick
