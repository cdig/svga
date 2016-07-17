Take ["Component", "ControlPanelView"], (Component, ControlPanelView )->
  
  instancesByNameByType = {}
  
  
  Make "Control", (args...)->
    if typeof args[0] is "string"
      Component.make "Control", args...
    else
      instantiate args...
  
  
  instantiate = (props)->
    type = props.type
    name = props.name or props.type
    defn = Component.take "Control", type
    
    if not type? then console.log(props); throw "^ You must include a \"type\" property when creating a Control instance"
    if not defn? then console.log(props); throw "^ Unknown Control type: \"#{type}\". First, check for typos. If everything looks good, this Control may have failed to load on time, which would mean there's a bug in the Control component."
    
    instancesByName = instancesByNameByType[type] ?= {}
    
    if not instancesByName[name]
      elm = ControlPanelView.createElement props
      scope = defn elm, props
      scope.element = elm
      ControlPanelView.setup scope
      instancesByName[name] =
        scope: scope
        props: props
    
    instancesByName[name].scope.attach? props
    
    instancesByName[name].scope # Composable
