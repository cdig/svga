# scope.setup
# Scope callback fired during initial setup.

Take ["Registry"], (Registry)->
  Registry.add "ScopeProcessor", (scope)->
    Take "ScopeSetup", ()-> scope.setup?()
