Take ["ControlPanel", "ControlPanelLayout", "Registry", "Scope"], (ControlPanel, ControlPanelLayout, Registry, Scope )->
  instances = {}
  
  Make "Control", Control = (type, defn)->
    Control[type] = (props)->
      
      # Re-using an existing ID? Just attach to the existing control.
      if props.id? and instances[props.id]?
        instances[props.id].attach? props
      
      # Create a new control
      else
        elm = ControlPanel.createElement props.parent
        scope = Scope elm, defn, props
        ControlPanelLayout.addScope scope
        instances[props.id] = scope if props.id?
