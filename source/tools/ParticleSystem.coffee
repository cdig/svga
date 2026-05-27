Take ["SVG"], (SVG) ->
  Make ["ParticleSystem"], (_opts) ->
    ParticleSystem =
        debugPath: null
        particles: []
        opts: _opts
        
        # Loop control state
        isRunning: false
        animationFrameId: null
        lastTime: 0

        updateDebugVisuals: () ->
            { origin, originWidth, angle, coneWidth, radius } = @opts.shape

            deg2rad = (d) -> d * Math.PI / 180
            sincos = (deg) ->
                r = deg2rad deg
                [Math.sin(r), -Math.cos(r)]

            [sx, sy] = sincos angle + 90
            half = originWidth / 2

            blx = origin.x - sx * half;  bly = origin.y - sy * half
            brx = origin.x + sx * half;  bry = origin.y + sy * half

            [arx, ary] = sincos angle + coneWidth / 2
            rtipX = brx + radius * arx;  rtipY = bry + radius * ary

            [alx, aly] = sincos angle - coneWidth / 2
            ltipX = blx + radius * alx;  ltipY = bly + radius * aly

            arcR = Math.sqrt (rtipX - origin.x) ** 2 + (rtipY - origin.y) ** 2
            largeArc = if coneWidth >= 180 then 1 else 0

            d = [
                "M #{blx} #{bly}"
                "L #{brx} #{bry}"
                "L #{rtipX} #{rtipY}"
                "A #{arcR} #{arcR} 0 #{largeArc} 0 #{ltipX} #{ltipY}"
                "Z"
            ].join " "

            if @debugPath?
                @debugPath.setAttribute "d", d
            else
                @debugPath = SVG.create "path", SVG.root,
                    d:      d
                    stroke: "#F0F"
                    fill:   "none"

        randomVariance: (base, variance) ->
            base + (Math.random() * 2 - 1) * variance

        rollParticleStats: () ->
            { particleLifeSeconds, particleLifeVarianceSeconds, particleSpeed, particleSpeedVariance, reverse } = @opts.particle
            life  = Math.max 0.1,  @randomVariance particleLifeSeconds,  particleLifeVarianceSeconds
            speed = Math.max 0.01, @randomVariance particleSpeed, particleSpeedVariance
            
            # These are now calculated per millisecond elapsed
            lifeStep:  if reverse then -(1 / (life * 1000)) else 1 / (life * 1000)
            speedStep: speed / 1000

        resetParticle: (system) ->
            { origin, originWidth, angle, coneWidth } = @opts.shape
            { reverse } = @opts.particle

            deg2rad = (d) -> d * Math.PI / 180
            sincos  = (deg) ->
                r = deg2rad deg
                [Math.sin(r), -Math.cos(r)]

            stats = @rollParticleStats()
            system.lifeStep  = stats.lifeStep
            system.speedStep = stats.speedStep

            t = Math.random() * 2 - 1
            [sx, sy] = sincos angle + 90
            system.baseX = origin.x + sx * (originWidth / 2) * t
            system.baseY = origin.y + sy * (originWidth / 2) * t

            if originWidth < 10
                spread = (Math.random() * 2 - 1) * (coneWidth / 2)
            else
                spread = t * (coneWidth / 2)

            system.travelAngle    = angle + spread
            system.travelDistance = if reverse then system.speedStep * (1 / Math.abs system.lifeStep) else 0
            system.phase          = if reverse then 1 else 0
            system.resetFlag      = false
            system.dormant        = false
            system.visible        = true

        preWarmParticle: (system) ->
            randomStartPhase = Math.random()
            maxLifeMs = 1 / Math.abs system.lifeStep
            timeInMs = randomStartPhase * maxLifeMs
            if @opts.particle.reverse
                system.phase          = 1 - randomStartPhase
                system.travelDistance = system.speedStep * maxLifeMs - system.speedStep * timeInMs
            else
                system.phase          = randomStartPhase
                system.travelDistance = system.speedStep * timeInMs

        createParticles: () ->
            { type, count, typeSpecificSettings = {} } = @opts.particle
            throttle = @opts.throttle ? 1

            @particles = for i in [0...count]
                particle = type typeSpecificSettings
                particle.createElement()

                shouldStartActive = i < (count * throttle)

                system =
                    x:              0
                    y:              0
                    phase:          0
                    travelDistance: 0
                    lifeStep:       0
                    speedStep:      0
                    resetFlag:      false
                    dormant:        false
                    visible:        shouldStartActive

                @resetParticle system

                if shouldStartActive
                    @preWarmParticle system
                else
                    system.phase    = if @opts.particle.reverse then 0 else 1
                    system.resetFlag = true
                    system.dormant  = true
                    system.visible  = false

                @updateParticlePosition system
                particle.system = system
                particle

        updateParticlePosition: (system) ->
            externalForce = @opts.particle.externalForce or {x: 0, y: 0}
            deg2rad = (d) -> d * Math.PI / 180
            sincos  = (deg) ->
                r = deg2rad deg
                [Math.sin(r), -Math.cos(r)]

            [dx, dy] = sincos system.travelAngle
            forceFactor = system.phase * system.phase

            system.x = system.baseX + dx * system.travelDistance + externalForce.x * forceFactor
            system.y = system.baseY + dy * system.travelDistance + externalForce.y * forceFactor

        # Note: Added deltaTime here to step smoothly across variable frame rates
        updateParticle: (particle, index, deltaTime) ->
            system = particle.system
            count  = @opts.particle.count
            throttle = @opts.throttle ? 1
            reverse = @opts.particle.reverse

            if system.resetFlag
                if index < (count * throttle)
                    wasDormant = system.dormant
                    @resetParticle system

                    if wasDormant
                        maxDelayMs = 1 / Math.abs system.lifeStep
                        system.spawnDelay = Math.random() * maxDelayMs
                        system.visible    = false
                else
                    system.visible = false
                    system.dormant = true
                    return

            if system.spawnDelay? and system.spawnDelay > 0
                system.spawnDelay -= deltaTime
                return

            if system.visible
                system.phase          += system.lifeStep * deltaTime
                system.travelDistance += (if reverse then -system.speedStep else system.speedStep) * deltaTime

                resetCondition = if reverse then system.phase <= 0 else system.phase >= 1
                if resetCondition
                    system.resetFlag = true

                @updateParticlePosition system
            else if system.spawnDelay? and system.spawnDelay <= 0
                system.visible    = true
                system.spawnDelay = null
                @updateParticlePosition system

        # Accepts a raw timestamp provided natively by requestAnimationFrame
        update: (timestamp) ->
            unless @lastTime
                @lastTime = timestamp

            # Calculate how many milliseconds have elapsed since the last frame
            deltaTime = timestamp - @lastTime
            @lastTime = timestamp

            # Cap deltaTime to prevent massive physics jumps if the browser stalls
            if deltaTime > 100 then deltaTime = 16.66 

            for particle, i in @particles
                @updateParticle particle, i, deltaTime
                particle.updateElement()

        # --- NEW ANIMATION FRAME CONTROL METHODS ---
        
        start: () ->
            return if @isRunning
            @isRunning = true
            @lastTime = 0 # Reset frame anchor
            
            loopFrame = (timestamp) =>
                unless @isRunning then return
                @update timestamp
                @animationFrameId = requestAnimationFrame loopFrame

            @animationFrameId = requestAnimationFrame loopFrame

        stop: () ->
            @isRunning = false
            if @animationFrameId?
                cancelAnimationFrame @animationFrameId
                @animationFrameId = null

    ParticleSystem.createParticles()
    return ParticleSystem
