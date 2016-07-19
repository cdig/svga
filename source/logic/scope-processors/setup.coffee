# scope.setup
# Scope callback fired during initial setup.

Take ["ScopeBuilder"], (ScopeBuilder)->
  ScopeBuilder.process (scope)->
    Take "ScopeSetup", ()-> scope.setup?()
