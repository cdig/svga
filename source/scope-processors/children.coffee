Take ["Registry", "ScopeCheck", "SVG"], (Registry, ScopeCheck, SVG)->
  Registry.add "ScopeProcessor", (scope)->

    # These functions don't change the DOM — they just control the scope hierarchy.
    ScopeCheck scope, "attachScope", "detachScope", "detachAllScopes"

    # These functions change both the DOM and scope hierarchy.
    # They're named to be compatable with the SVG tools.
    ScopeCheck scope, "append", "prepend", "remove", "removeAllChildren"


    scope.attachScope = (child, prepend = false)->
      child.parent = scope
      child.id ?= "child" + (scope.children.length or 0)
      if scope[child.id]?
        tempID = child.id.replace /\d/g, ""
        idCounter = 1
        while scope[tempID + idCounter]?
          idCounter++
        child.id = tempID + idCounter
      scope[child.id] = child
      if prepend
        scope.children.unshift child
      else
        scope.children.push child

    scope.detachScope = (child)->
      scope.children.splice(i, 1) for c, i in scope.children by -1 when c is child
      delete scope[child.id]
      delete child.id if child.id.indexOf("child") isnt -1
      delete child.parent

    scope.detachAllScopes = ()->
      for child in scope.children
        delete scope[child.id]
        delete child.id if child.id.indexOf("child") isnt -1
        delete child.parent
      scope.children = []


    scope.append = (child)->
      SVG.append scope.element, child.element
      scope.attachScope child

    scope.prepend = (child)->
      SVG.prepend scope.element, child.element
      scope.attachScope child, true

    scope.remove = (child)->
      SVG.remove scope.element, child.element
      scope.detachScope child

    scope.removeAllChildren = ()->
      SVG.removeAllChildren scope.element
      scope.detachAllScopes()
