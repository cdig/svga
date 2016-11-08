Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "text"
    
    element = scope.element
    textElement = element.querySelector "tspan" or element.querySelector "text"
    text = textElement?.textContent
    alignment = "start"
    
    Object.defineProperty scope, 'align',
      get: ()-> alignment
      set: (val)->
        if not textElement? then throw new Error "You have #{scope.id}.align = '#{val}', but this scope doesn't contain any text or tspan elements."
        if alignment isnt val
          alignment = val
          SVG.attr textElement, "textAnchor", if val is "left" then "start" else if val is "center" then "middle" else "end"

    Object.defineProperty scope, 'text',
      get: ()-> text
      set: (val)->
        if not textElement? then throw new Error "You have #{scope.id}.text = '#{val}', but this scope doesn't contain any text or tspan elements."
        if text isnt val
          SVG.attr textElement, "textContent", text = val
