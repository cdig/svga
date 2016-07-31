Take ["Dev", "Registry", "ScopeCheck", "Symbol"], (Dev, Registry, ScopeCheck, Symbol)->
  Make "Scope", Scope = (element, parentScope = null, symbol = null, props = null)->
    
    instanceName = element.id?.split("_")[0]
    ScopeCheck parentScope, instanceName if parentScope?
    
    symbol ?= if (s = Symbol.forInstanceName element.id)?
      s
    else if instanceName?.indexOf("Line") > -1
      Symbol.forSymbolName "HydraulicLine"
    else if instanceName?.indexOf("Field") > -1
      Symbol.forSymbolName "HydraulicField"
    
    # Create the scope
    scope = if symbol? then symbol element, props else {}
    
    ScopeCheck scope, "_symbol", "children", "element", "instanceName", "parent", "root"
    
    # Private APIs
    element._scope = scope
    scope._symbol = symbol
    
    # Public APIs
    scope.children = []
    scope.element = element
    scope.instanceName = instanceName or ("child" + (parentScope?.children.length or 0))
    scope.parent = parentScope
    scope.root = Scope.root ?= scope
    
    # Set up parent-child relationship
    if scope.parent?[scope.instanceName]? then console.log scope.parent; throw "^^^ Has multiple children with the instance name \"#{scope.instanceName}\"."
    scope.parent?[scope.instanceName] ?= scope
    scope.parent?.children.push scope
    
    # Run this scope through all the processors, which add special properties, callbacks, and other fanciness
    scopeProcessor scope for scopeProcessor in Registry.all "ScopeProcessor"
    
    # Add the "scope-name" attribute to the element
    if Dev
      element.setAttribute "instance-name", scope.instanceName
      attrs = Array.prototype.slice.call element.attributes
      for attr in attrs when attr.name isnt "instance-name"
        element.removeAttributeNS attr.namespaceURI, attr.name
        element.setAttributeNS attr.namespaceURI, attr.name, attr.value
    
    return scope
