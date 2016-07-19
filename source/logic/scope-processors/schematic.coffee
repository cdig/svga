# scope.animateMode and scope.schematicMode
# Scope callbacks fired whenever we switch modes

Take ["Reaction", "ScopeBuilder"], (Reaction, ScopeBuilder)->
  ScopeBuilder.process (scope)->
    Reaction "Schematic:Hide", ()-> scope.animateMode?()
    Reaction "Schematic:Show", ()-> scope.schematicMode?()
