Take ["ControlPanel", "ControlPanelLayout", "Registry", "Scope", "ControlReady"], (ControlPanel, ControlPanelLayout, Registry, Scope)->
  Control = {}
  instances = {}
  
  setup = (type, defn)->
    Control[type] = (props = {})->
      if typeof props isnt "object" then console.log props; throw new Error "Control.#{type}(props) takes a optional props object. Got ^^^, which is not an object."
      
      # Re-using an existing ID? Just attach to the existing control.
      if props?.id? and instances[props.id]?
        instances[props.id].attach? props
        return instances[props.id]
        
      # Create a new control
      else
        elm = ControlPanel.createItemElement props?.parent
        scope = Scope elm, defn, props
        
        # Controls should not call attach themselves.
        # We'll always do the attaching, for consistency sake.
        scope.attach? props
        
        ControlPanel.registerItemScope scope
        instances[props.id] = scope if props?.id?
        return scope
  
  
  setup type, defn for type, defn of Registry.all "Control", true
  Make "Control", Control
