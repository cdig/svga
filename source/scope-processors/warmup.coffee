Take ["Registry", "ScopeCheck"], (Registry, ScopeCheck)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "warmup"

    runtimeLimit = 300 # ms

    warmup = (fn, time, step)->
      return unless fn?
      start = performance.now()
      while time <= 0
        fn time, step
        time += step
        runtime = performance.now() - start
        if runtime > runtimeLimit
          console.log "Warning: Warmup took longer than #{runtimeLimit}ms — aborting."
          return
      msg = "@warmup took #{Math.round runtime}ms"
      msg += " — please simplify your function or reduce the warmup duration" if runtime > runtimeLimit/3
      console.log msg

    scope.warmup = (duration)-> # duration: seconds
      warmup scope._ms, -duration, 1/1000
      warmup scope._tick, -duration, 1/60
      warmup scope._rawTick, -duration, 1/60
