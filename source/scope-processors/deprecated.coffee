# This adds various deprecated properties, to ease the migration.

Take ["Registry"], (Registry)->
  Registry.add "ScopeProcessor", (scope)->
    
    Object.defineProperty scope, "FlowArrows",
      get: ()-> throw "root.FlowArrows has been removed. Please use FlowArrows instead."
    
    scope.getElement ?= ()->
      throw "@getElement() has been removed. Please use @element instead."
