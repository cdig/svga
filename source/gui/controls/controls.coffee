Take ["ControlPanel", "ControlPanelLayout", "Registry", "Scope"], (ControlPanel, ControlPanelLayout, Registry, Scope )->
  instancesById = {}
  
  Make "Control", Control = (args...)->
    if typeof args[0] is "string"
      [type, defn] = args
      Registry.set "Control", type, defn
    else if args[0]?
      props = args[0]
      type = props.type
      if not type? then console.log(props); throw "^ You must include a \"type\" property when creating a Control instance."
      defn = Registry.get "Control", type
      if not defn? then console.log(props); throw "^ Unknown Control type: \"#{type}\"."
      instantiate defn, props
    else
      throw "Control(null) is bad, don't do that."
  
  
  instantiate = (defn, props)->
    # Re-using an existing ID? Just attach to the existing control.
    if props.id? and instancesById[props.id]?
      instancesById[props.id].attach? props
    
    # Create a new control
    else
      elm = ControlPanel.createElement props.parent
      scope = Scope elm, defn, props
      ControlPanelLayout.addScope scope
      instancesById[props.id] = scope if props.id?
