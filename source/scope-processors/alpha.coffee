Take ["Ease", "Registry", "ScopeCheck", "SVG"], (Ease, Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "alpha"

    element = scope.element
    placeholder = SVG.create "g"
    alpha = 1

    Object.defineProperty scope, 'alpha',
      get: ()-> alpha
      set: (val)->
        val = 1 if val is true
        val = 0 if !val
        if alpha isnt val
          SVG.style element, "opacity", alpha = Ease.clip val
          if alpha > 0
            placeholder.parentNode.replaceChild element, placeholder if placeholder.parentNode?
          else
            element.parentNode.replaceChild placeholder, element if element.parentNode?
