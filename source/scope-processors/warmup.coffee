Take ["Registry", "ScopeCheck"], (Registry, ScopeCheck)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "warmup"

    runtimeLimit = 100 # ms
    dt = 1/60 # seconds

    scope.warmup = (duration, ...fns)->
      start = performance.now()

      unless fns?.length
        fns = [scope._tick, scope._rawTick]

      time = -duration # seconds

      while time <= 0
        fn?.call scope, time, dt for fn in fns
        time += dt

        runtime = performance.now() - start
        if runtime > runtimeLimit
          console.log "Warning: Warmup took longer than #{runtimeLimit}ms — aborting."
          return

      msg = "@warmup took #{Math.round runtime}ms"
      msg += " — please simplify your function or reduce the warmup duration" if runtime > runtimeLimit/3
      console.log msg
