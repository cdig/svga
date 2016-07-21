Take ["Registry"], (Registry)->
  Registry.add "ScopeProcessor", (scope)->
    
    if scope.parent?
      
      if scope.parent[scope.name]?.element.id is scope.element.id
        console.log scope.parent
        throw "Duplicate instance name detected in ^^^ #{scope.parent.name}: #{scope.name}"
      
      scope.parent[scope.name] ?= scope
      scope.parent.children.push scope