Make "ScopeCheck", (scope, props...)->
  for prop in props when scope[prop]?
    console.log scope.element
    throw new Error "^ @#{prop} is a reserved name. Please choose a different name for your child/property \"#{prop}\"."
