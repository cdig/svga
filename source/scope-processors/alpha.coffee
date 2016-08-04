Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "alpha"
    
    element = scope.element
    parent = element.parentNode
    placeholder = SVG.create "g"
    alpha = 1
    
    Object.defineProperty scope, 'alpha',
      get: ()-> alpha
      set: (val)->
        val = 1 if val is true
        val = 0 if val is false
        if alpha isnt val
          SVG.style element, "opacity", alpha = val
          if alpha > 0
            parent.replaceChild element, placeholder if placeholder.parentNode?
          else
            parent.replaceChild placeholder, element if element.parentNode?
