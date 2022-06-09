Take ["Mode", "Registry", "ScopeCheck", "Scope", "SVG"], (Mode, Registry, ScopeCheck, Scope, SVG)->
  Registry.add "ScopeProcessor", (scope)->

    ScopeCheck scope, "debug"

    Object.defineProperty scope, 'debug', get: ()->

      controls: ()->
        Control = Take "Control"
        Control.slider
          name: "Speed"
          group: "#f70"
          value: 1
          change: (v)=>
            v = if v is 0 then 0 else Math.pow(500, v)/500
            scope.rawTick?.speed v
            scope.tick?.speed v
            scope.ms?.speed v
            Take("FlowArrows")?.speed = 0.005 + v * 0.995

        Control.button
          name: "Step"
          group: "#f70"
          click: ()=>
            scope.rawTick?.step()
            scope.tick?.step()
            scope.ms?.step()

      point: (color)->
        if Mode.dev
          point = Scope SVG.create "g", scope.element
          SVG.create "rect", point.element, fill: "#000", x:0, y:0, width: 10, height: 10 if color?
          SVG.create "rect", point.element, fill: color, x:0, y:0, width: 9, height: 9 if color?
          SVG.create "rect", point.element, fill: "#000", x:-1, y:-1, width: 2, height: 2
          SVG.create "rect", point.element, fill: "#FFF", x:-.5, y:-.5, width: 1, height: 1

          SVG.create "rect", point.element, fill: "#FFF", x:1, y:-1, width: 48, height: 2
          SVG.create "rect", point.element, fill: "#F00", x:1, y:-.5, width: 48, height: 1

          SVG.create "rect", point.element, fill: "#000", x:-1, y:1, width: 2, height: 48
          SVG.create "rect", point.element, fill: "#0F0", x:-.5, y:1, width: 1, height: 48
          return point
        else
          "Warning: @debug.point() is disabled unless you're in dev"
          return {}
