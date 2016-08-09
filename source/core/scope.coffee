Take ["Dev", "Registry", "ScopeCheck", "Symbol"], (Dev, Registry, ScopeCheck, Symbol)->
  Make "Scope", Scope = (element, symbol, props = {})->
    if not element instanceof SVGElement then console.log element; throw "Scope() takes an element as the first argument. Got ^^^"
    if symbol? and typeof symbol isnt "function" then console.log symbol; throw "Scope() takes a function as the second arg. Got ^^^"
    if typeof props isnt "object" then console.log props; throw "Scope() takes an optional object as the third arg. Got ^^^"
    
    scope = if symbol? then symbol element, props else {}
    parentScope = props.parent or findParent element
    
    ScopeCheck scope, "_symbol", "children", "element", "id", "parent", "root"
    
    # Private APIs
    element._scope = scope
    scope._symbol = symbol
    
    # Public APIs
    scope.children = []
    scope.element = element
    scope.root = Scope.root ?= scope # It is assumed that the very first scope created is the root scope.
    scope.id = props.id
    
    # Set up parent-child relationship
    if parentScope?
      scope.parent = parentScope
      scope.id ?= "child" + (parentScope.children.length or 0)
      if parentScope[scope.id]? then console.log parentScope; throw "^ Has a child or property with the id \"#{scope.id}\". This is conflicting with a child scope that wants to use that instance name."
      parentScope[scope.id] ?= scope
      parentScope.children.push scope
    
    # Add some info to help devs locate scope elements in the DOM
    if Dev
      # Add some helpful dev names to the element
      console.log symbol?.symbolName
      element.setAttribute "SCOPE", scope.id or ""
      element.setAttribute "SYMBOL", symbol.symbolName if symbol?.symbolName?
      attrs = Array.prototype.slice.call element.attributes
      for attr in attrs when attr.name isnt "SCOPE" and attr.name isnt "SYMBOL" # Sort attrs so that dev names come first
        element.removeAttributeNS attr.namespaceURI, attr.name
        element.setAttributeNS attr.namespaceURI, attr.name, attr.value
    
    # Run this scope through all the processors, which add special properties, callbacks, and other fanciness
    scopeProcessor scope for scopeProcessor in Registry.all "ScopeProcessor"
    
    return scope
  
  
  findParent = (element)->
    while element?
      return element._scope if element._scope?
      element = element.parentNode
    return null # needed, because while returns an array
