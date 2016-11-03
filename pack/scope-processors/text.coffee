Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "text"
    
    element = scope.element
    textElement = element.querySelector "tspan" or element.querySelector "text"
    text = textElement?.textContent
    
    Object.defineProperty scope, 'text',
      get: ()-> text
      set: (val)->
        if not textElement? then console.log scope; throw new Error "^^^ You called .text = '#{val}' but this scope doesn't contain any text or tspan elements."
        if text isnt val
          SVG.attr textElement, "textContent", text = val
