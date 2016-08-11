Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "text"
    
    element = scope.element
    textElement = element.querySelector "tspan" or element.querySelector "text"
    text = textElement?.textContent
    
    Object.defineProperty scope, 'text',
      get: ()-> text
      set: (val)->
        if text isnt val
          SVG.attr "textContent", text = val
