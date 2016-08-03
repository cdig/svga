Take ["Dev", "Registry", "ScopeCheck", "Symbol"], (Dev, Registry, ScopeCheck, Symbol)->
  Make "Scope", Scope = (element, symbol, props = {})->
    if typeof symbol isnt "function" then throw "Scope() takes a function as the first arg. Got: #{symbol}"
    if not element instanceof SVGElement then throw "Scope() takes an element as the second argument. Got: #{element}"
    
    scope = if symbol? then symbol element, props else {}
    parentScope = props.parent or findParent element
    
    ScopeCheck scope, "_symbol", "children", "element", "id", "parent", "root"
    
    # Private APIs
    element._scope = scope
    scope._symbol = symbol
    
    # Public APIs
    scope.children = []
    scope.element = element
    scope.id = props.id or ("child" + (parentScope?.children.length or 0))
    scope.parent = parentScope
    scope.root = Scope.root ?= scope # It is assumed that the very first scope created is the root scope.
    
    # Set up parent-child relationship
    if scope.parent?
      if scope.parent[scope.id]? then console.log scope.parent; throw "^ Has a child or property with the id \"#{scope.id}\". This is conflicting with a child scope that wants to use that instance name."
      scope.parent[scope.id] ?= scope
      scope.parent.children.push scope
    
    # Run this scope through all the processors, which add special properties, callbacks, and other fanciness
    scopeProcessor scope for scopeProcessor in Registry.all "ScopeProcessor"
    
    if Dev
      element.setAttribute "scope-id", scope.id # Add the "scope-id" attribute to the element
      attrs = Array.prototype.slice.call element.attributes
      for attr in attrs when attr.name isnt "scope-id" # Sort attrs so that scope-id comes first
        element.removeAttributeNS attr.namespaceURI, attr.name
        element.setAttributeNS attr.namespaceURI, attr.name, attr.value
    
    return scope
  
  
  findParent = (element)->
    while element?
      return element._scope if element._scope?
      element = element.parentNode
    return null # needed, because while returns an array
