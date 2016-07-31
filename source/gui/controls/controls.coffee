Take ["ControlPanelView", "Registry", "Scope"], (ControlPanelView, Registry, Scope )->
  
  instancesByNameByType = {}
  
  
  Make "Control", Control = (args...)->
    if typeof args[0] is "string"
      [type, fn] = args
      Control[type] = build type # Simple control
      Registry.set "Control", type, fn
    else
      instantiate args... # Advanced control
  
  
  build = (type)-> (name, action)->
    instantiate type:type, name:name, action:action
    
  
  instantiate = (props)->
    type = props.type
    name = props.name or props.type
    defn = Registry.get "Control", type
    
    if not type? then console.log(props); throw "^ You must include a \"type\" property when creating a Control instance."
    if not defn? then console.log(props); throw "^ Unknown Control type: \"#{type}\"."
    
    instancesByName = instancesByNameByType[type] ?= {}
    
    if not instancesByName[name]
      elm = ControlPanelView.createElement props
      
      # Can we get the View's scope in here?
      scope = Scope elm, null, defn, props
      
      ControlPanelView.setup scope, props
      
      instancesByName[name] =
        scope: scope
        props: props
    
    instancesByName[name].scope.attach? props
    
    instancesByName[name].scope # Composable
