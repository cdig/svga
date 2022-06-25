# scope.ms
# An every-frame update function that can be turned on and off by the content creator.
# The frame rate is capped to 1000 Hz but otherwise approximates display refresh rate.

Take ["Registry", "Tick"], (Registry, Tick)->

  speed = 1

  Registry.add "ScopeProcessor", (scope)->
    return unless scope.ms?

    running = true
    acc = 0
    count = 0
    step = 1/1000

    # Replace the actual scope ms function with a warning
    ms = scope.ms
    scope.ms = ()-> throw new Error "@ms() is called by the system. Please don't call it yourself."

    scope.ms.start = ()->
      running = true

    scope.ms.stop = ()->
      running = false

    scope.ms.toggle = ()->
      if running then scope.ms.stop() else scope.ms.start()

    scope.ms.restart = ()->
      acc = 0
      count = 0

    scope.ms.speed = (s)->
      speed = s if s?
      speed

    scope.ms.step = ()->
      count++
      ms.call scope, count * step, step

    # Store a secret copy of the real ms function, so that warmup can use it
    scope._ms = (time, dt)->
      return unless running
      acc += dt * speed
      while acc > step and running
        acc -= step
        scope.ms.step()

    Tick scope._ms
