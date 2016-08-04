Take ["ControlPanel", "ControlPanelLayout", "Scope"], (ControlPanel, ControlPanelLayout, Scope )->
  instances = {}
  
  Make "Control", Control = (type, defn)->
    
    # This Control[type] = ()-> stuff establishes the Control.foo syntax for creating controls.
    # We don't get the benefit of nice errors if a control definiton is too late to init,
    # but because creating controls is an advanced topic, we can be confident that
    # people creating controls will be able to work around this constraint, and that
    # the benefit to people using controls is well worth it.
    
    Control[type] = (props)->
      
      # Re-using an existing ID? Just attach to the existing control.
      if props.id? and instances[props.id]?
        instances[props.id].attach? props
      
      # Create a new control
      else
        elm = ControlPanel.createElement props.parent
        scope = Scope elm, defn, props
        
        # Controls should not call attach themselves.
        # We'll always do the attaching, for consistency sake.
        scope.attach? props
        
        ControlPanelLayout.addScope scope
        instances[props.id] = scope if props.id?
