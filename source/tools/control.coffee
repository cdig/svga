Take ["ControlPanel", "ControlPanelLayout", "GUI", "Registry", "Scope", "SVG", "ControlReady"], (ControlPanel, ControlPanelLayout, {ControlPanel:GUI}, Registry, Scope, SVG)->
  Control = {}
  instances = {}
  currentGroup = null
  
  getGroup = (color)->
    if !currentGroup? or !color? or color isnt currentGroup.color
      elm = SVG.create "g", null
      bg = SVG.create "rect", elm,
        width: GUI.colInnerWidth + GUI.groupPad*2
        rx: GUI.groupBorderRadius
        fill: color or "transparent"
      ControlPanel.registerGroup currentGroup =
        scope: Scope elm
        bg: bg
        color: color
        itemScopes: []
        height: GUI.groupPad*2
    return currentGroup
  
  addItemToGroup = (group, scope)->
    group.height += GUI.itemMargin if group.itemScopes.length > 0
    scope.x = GUI.groupPad
    scope.y = group.height - GUI.groupPad
    group.height += scope.height
    SVG.attrs group.bg, height: group.height
    group.itemScopes.push scope
  
  setup = (type, defn)->
    Control[type] = (props = {})->
      if typeof props isnt "object" then console.log props; throw new Error "Control.#{type}(props) takes a optional props object. Got ^^^, which is not an object."
      
      # Re-using an existing ID? Just attach to the existing control.
      if props.id? and instances[props.id]?
        instances[props.id].attach? props
        return instances[props.id]
      
      # Create a new control
      else
        group = getGroup props.group
        elm = ControlPanel.createItemElement props.parent or group.scope.element
        
        # We check for this property in some control-specific scope-processors
        props._isControl = true
        
        scope = Scope elm, defn, props
        addItemToGroup group, scope
        
        # Controls should not call attach themselves.
        # We'll always do the attaching, for consistency sake.
        scope.attach? props
        
        # We don't want controls to highlight when they're hovered over,
        # so we flag them in a way that highlight can see.
        scope._dontHighlightOnHover = true
        
        instances[props.id] = scope if props.id?
        return scope
  
  
  setup type, defn for type, defn of Registry.all "Control", true
  Make "Control", Control
