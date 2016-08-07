# Most deprecations are handled by v2-to-v3.coffee
# This is just a fallback for things that haven't been automated yet.

Take ["Registry"], (Registry)->
  Registry.add "ScopeProcessor", (scope)->
    scope.getPressureColor = ()-> throw "@getPressureColor() has been removed. Please Take and use Pressure() instead."
    scope.setText = ()-> throw "@setText(x) has been removed. Please @text = x instead."
    Object.defineProperty scope, "cx", get: ()-> throw "cx has been removed."
    Object.defineProperty scope, "cy", get: ()-> throw "cy has been removed."
    Object.defineProperty scope, "turns", get: ()-> throw "turns has been removed. Please use @rotation instead."
