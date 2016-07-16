Take ["Component", "ControlPanelView"], (Component, ControlPanelView )->
  
  instancesByNameByType = {}
  
  
  Make "Control", (args...)->
    if typeof args[0] is "string"
      Component.make "Control", args...
    else
      instantiate args...
  
  
  instantiate = (props)->
    name = props.name
    type = props.type
    defn = Component.take "Control", type
    
    if not name? then console.log(props); throw "^ You must include a \"name\" property when creating a Control instance"
    if not type? then console.log(props); throw "^ You must include a \"type\" property when creating a Control instance"
    if not defn? then console.log(props); throw "^ Unknown Control type: \"#{type}\". First, check for typos. If everything looks good, this Control may have failed to load on time, which would mean there's a bug in the Control component."
    
    instancesByName = instancesByNameByType[type] ?= {}
    
    if not instancesByName[name]
      element = ControlPanelView.createElement name, type
      api = defn name, element
      api.setup?()
      
      ControlPanelView.position element, props.x, props.y
      
      instancesByName[name] =
        element: element
        api: api
    
    instancesByName[name].api.attach props
    
    instancesByName[name].api # Composable
