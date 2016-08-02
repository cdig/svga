Take ["ControlPanelView", "Registry", "Scope"], (ControlPanelView, Registry, Scope )->
  
  instancesById = {}
  
  
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
    if instancesById[props.id]?
      instancesById[props.id].attach? props
    
    else
      type = props.type
      if not type? then console.log(props); throw "^ You must include a \"type\" property when creating a Control instance."
      
      defn = Registry.get "Control", type
      if not defn? then console.log(props); throw "^ Unknown Control type: \"#{type}\"."
      
      elm = ControlPanelView.createElement props.parent
      scope = Scope defn, elm, props
      
      ControlPanelView.layout scope
      instancesById[props.id] = scope if props.id?
