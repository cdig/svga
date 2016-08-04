# This adds various deprecated properties, to ease the migration.

Take ["Registry", "ScopeCheck"], (Registry, ScopeCheck)->
  Registry.add "ScopeProcessor", (scope)->
    ScopeCheck scope, "getElement", "getPressure", "setPressure", "getPressureColor", "setText", "FlowArrows", "cx", "cy", "angle", "turns", "transform"
    
    scope.getElement = ()-> throw "@getElement() has been removed. Please use @element instead."
    scope.getPressure = ()-> throw "@getPressure() has been removed. Please use @pressure instead."
    scope.setPressure = ()-> throw "@setPressure(x) has been removed. Please use @pressure = x instead."
    scope.getPressureColor = ()-> throw "@getPressureColor() has been removed. Please Take and use Pressure() instead."
    scope.setText = ()-> throw "@setText(x) has been removed. Please @text = x instead."
    
    Object.defineProperty scope, "FlowArrows", get: ()-> throw "root.FlowArrows has been removed. Please access FlowArrows via Take."
    Object.defineProperty scope, "cx", get: ()-> throw "cx has been removed."
    Object.defineProperty scope, "cy", get: ()-> throw "cy has been removed."
    Object.defineProperty scope, "angle", get: ()-> throw "angle has been removed. Please use @rotation instead."
    Object.defineProperty scope, "turns", get: ()-> throw "turns has been removed. Please use @rotation instead."
    Object.defineProperty scope, "transform", get: ()-> throw "@transform has been removed. You can just delete the \"transform.\" and things should work."
