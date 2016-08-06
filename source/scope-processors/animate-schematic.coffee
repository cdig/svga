# scope.animateMode and scope.schematicMode
# Scope callbacks fired whenever we switch modes

Take ["Reaction", "Registry"], (Reaction, Registry)->
  Registry.add "ScopeProcessor", (scope)->
    Reaction "Schematic:Hide", ()-> scope.animateMode?()
    Reaction "Schematic:Show", ()-> scope.schematicMode?()
