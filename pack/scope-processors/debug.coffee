Take ["Mode", "Registry", "ScopeCheck", "Scope", "SVG"], (Mode, Registry, ScopeCheck, Scope, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    
    ScopeCheck scope, "debug"
    
    Object.defineProperty scope, 'debug', get: ()->
      
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
