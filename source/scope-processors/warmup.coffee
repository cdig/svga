Take ["Registry", "ScopeCheck"], (Registry, ScopeCheck)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "warmup"

    runtimeLimit = 100 # ms
    step = 1/1000

    scope.warmup = (duration)->
      start = performance.now()

      time = -duration # seconds

      while time <= 0

        scope._ms time, step
        scope._tick time, step
        time += step

        runtime = performance.now() - start
        if runtime > runtimeLimit
          console.log "Warning: Warmup took longer than #{runtimeLimit}ms — aborting."
          return

      msg = "@warmup took #{Math.round runtime}ms"
      msg += " — please simplify your function or reduce the warmup duration" if runtime > runtimeLimit/3
      console.log msg
