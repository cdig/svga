Take ["ACLine:dot", "ACLine:line", "SVG"], (Dot, Line, SVG) ->

    # ── Shared scheduler ──────────────────────────────────────────────────────
    TARGET_FPS    = 60
    TARGET_INTERVAL = 1000 / TARGET_FPS
    _instances    = []
    _rafHandle    = null
    _lastTime     = null

    _tick = (timestamp) ->
        _rafHandle = requestAnimationFrame _tick          # schedule next before work

        _lastTime ?= timestamp
        elapsed = timestamp - _lastTime
        return if elapsed < TARGET_INTERVAL * 0.9        # gate to target fps

        dt = Math.min(elapsed, TARGET_INTERVAL * 3) / TARGET_INTERVAL
        _lastTime = timestamp

        inst.step dt for inst in _instances              # drive every line

    _register = (inst) ->
        _instances.push inst
        if _instances.length is 1                        # first line starts the loop
            _lastTime = null
            _rafHandle = requestAnimationFrame _tick

    _unregister = (inst) ->
        _instances = _instances.filter (i) -> i isnt inst
        if _instances.length is 0
            cancelAnimationFrame _rafHandle
            _rafHandle = null
    # ──────────────────────────────────────────────────────────────────────────

    ACLine = (scope, segments...) ->
        line = Line segments

        hideMarkerBoxAndLine = () ->
            for child in scope.children
                child.hide(false)

        createDots = (acl) ->
            dotsArray = []
            for offset in [0...line.totalLength] by acl.spacing
                d = Dot acl, scope, line.offsetToPos offset
                d.startOffset = offset
                dotsArray.push d
            dotsArray

        acl =
            MAX_DOT_TRAVEL: 30
            flow:       0.5
            _flow:      0.5
            wiggle:     0
            shift:      0
            phase:      0
            _phase:     0
            wigglePhase: 0
            frequency:  0.5
            _frequency: 0.5
            _reversed:  false
            scale:      ACLine.SCALE
            _spacing:   ACLine.SPACING

            # Flips which end of the point list is treated as the start.
            # Chainable, and toggles back if called again.
            reverse: ->
                @_reversed = not @_reversed
                @

            # Called by the shared scheduler with a normalised dt
            step: (dt) ->
                @_flow      = 0.2 * Math.abs(@flow) + 0.8 * @_flow
                @_frequency = 0.5 * @frequency      + 0.5 * @_frequency
                @_phase     = 0.5 * @phase          + 0.5 * @_phase

                @wigglePhase = (@wigglePhase + 0.1 * @_frequency * 2 * dt) % (Math.PI * 2)

                @wiggle = Math.sin(@wigglePhase + @_phase / 57.295) * @MAX_DOT_TRAVEL / 2
                @radius = (2 + Math.abs(Math.cos(@wigglePhase + @_phase / 57.295)) * 1.5) * @_flow * @scale

                for d in @dots
                    targetOffset = d.startOffset + @wiggle + @shift
                    targetOffset = line.totalLength - targetOffset if @_reversed

                    if targetOffset < 0 or targetOffset > line.totalLength
                        d.setVisible false
                    else
                        d.setVisible true
                        d.update (line.offsetToPos targetOffset), @

            destroy: ->
                _unregister @

        # Re-lays-out the dots (and cleans up their old DOM elements) whenever spacing changes.
        Object.defineProperty acl, "spacing",
            get: -> @_spacing
            set: (value) ->
                return if value is @_spacing
                @_spacing = value
                (SVG.remove scope.element, d.ele) for d in @dots if @dots?
                @dots = createDots @

        hideMarkerBoxAndLine()
        acl.dots = createDots acl
        _register acl
        acl

    ACLine.computeLineColor = (color) -> undefined
    ACLine.SCALE ?= 1
    ACLine.SPACING ?= 60

    Make ["ACLine"], ACLine