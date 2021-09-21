Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->

    props = ["fill", "stroke", "strokeLinecap", "strokeLinejoin", "strokeWidth"]

    childPaths = scope.element.querySelectorAll "path"

    props.forEach (prop)->

      ScopeCheck scope, prop

      value = null
      childPropsCleared = false

      Object.defineProperty scope, prop,
        get: ()-> value
        set: (v)->
          if value isnt v
            SVG.attr scope.element, prop, value = v

            unless childPropsCleared
              childPropsCleared = true
              for childPath in childPaths
                SVG.attr childPath, prop, null
