Take ["SVG", "AC"], (SVG, AC) ->
    Make ["ACLine:dot"], (parentLine, scope, opts) ->
        ele = SVG.create "circle", scope.element,
            r: 4
            cx: opts.x
            cy: opts.y

        d =
            ele:      ele
            pressure: 0
            visible:  true

            update: (point, ACLine) ->
                SVG.attrs @ele,
                    cx: point.x
                    cy: point.y
                    r:  ACLine.radius
                    fill: AC(ACLine.phase, ACLine.voltage)

            setVisible: (visible) ->
                return if visible is @visible
                @visible = visible
                SVG.attrs @ele, opacity: (if visible then 1 else 0)

        return d