Take ["Registry"], (Registry)->
  Registry.add "ScopeProcessor", (scope)->
    
    if scope.parent?
      
      if scope.parent[scope.instanceName]?.element.id is scope.element.id
        console.log scope.parent
        throw "Duplicate instance name detected in ^^^ #{scope.parent.instanceName}: #{scope.instanceName}"
      
      scope.parent[scope.instanceName] ?= scope
      scope.parent.children.push scope
