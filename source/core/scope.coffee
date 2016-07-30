Take ["Dev", "Registry", "ScopeCheck", "Symbol"], (Dev, Registry, ScopeCheck, Symbol)->
  Make "Scope", Scope = (element, parentScope = null, symbol = null)->
    
    instanceName = element.id?.split("_")[0] or ("child" + (parentScope?.children.length or 0))
    ScopeCheck parentScope, instanceName if parentScope?
    
    # Figure out which Symbol we should use to create the scope
    if (s = Symbol.forInstanceName element.id)?
      symbol = s
      instanceName = element.id
    else if instanceName?.indexOf("Line") > -1
      symbol = Symbol.forSymbolName "HydraulicLine"
    else if instanceName?.indexOf("Field") > -1
      symbol = Symbol.forSymbolName "HydraulicField"
    
    # Create the scope
    scope = if symbol? then symbol.create element else {}
    
    ScopeCheck scope, "_symbol", "children", "element", "instanceName", "parent", "root"
    
    # Private APIs
    element._scope = scope
    scope._symbol = symbol
    
    # Public APIs
    scope.children = []
    scope.element = element
    scope.instanceName = instanceName
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
