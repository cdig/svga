Take ["Component","PointerInput","Reaction","Resize","SVG","TopBar","TRS","Tween1"],
(      Component , PointerInput , Reaction , Resize , SVG , TopBar , TRS , Tween1)->
  pad = 5
  panelX = 1
  instancesByNameByType = {}
  
  g = TRS SVG.create "g", SVG.root, class: "Controls", "font-size": 20, "text-anchor": "middle"
  bg = SVG.create "rect", g, class: "BG"
  
  
  Control = (args...)->
    if typeof args[0] is "string"
      Component.make "Control", args...
    else
      instantiate args...
  
  Control.panelWidth = 0
  Control.panelShowing = false
  
  resize = ()->
    panelWidth = Control.panelWidth = Math.ceil 3 * Math.sqrt window.innerWidth
    SVG.attr bg, "width", panelWidth
    SVG.attr bg, "height", window.innerHeight - TopBar.height
    positionPanel()
    offset = pad
    for type, instancesByName of instancesByNameByType
      for name, control of instancesByName
        height = control.api.resize panelWidth-pad*2
        if typeof height isnt "number" then console.log control; throw "Control api.resize() function must return a height"
        TRS.move control.element, pad, offset
        offset += height + pad
  
  
  instantiate = (props)->
    name = props.name
    type = props.type
    defn = Component.take "Control", type
    if not name? then console.log(props); throw "^ You must include a \"name\" property when creating an SVGA.control instance"
    if not type? then console.log(props); throw "^ You must include a \"type\" property when creating an SVGA.control instance"
    if not defn? then console.log(props); throw "^ Unknown Control type: \"#{type}\". First, check for typos. If everything looks good, this Control may have failed to load on time, which would mean there's a bug in the Control component."
    instancesByName = instancesByNameByType[type] ?= {}
    if not instancesByName[name]
      element = TRS SVG.create "g", g, class: "#{name} #{type}", ui: true
      api = defn name, element
      api.setup?()
      instancesByName[name] = element: element, api: api
    instancesByName[name].api.attach props
    instancesByName[name].api
  
  
  positionPanel = ()->
    TRS.move g, window.innerWidth - Control.panelWidth * panelX, TopBar.height

  tick = (v)->
    panelX = v
    positionPanel()
  
  Reaction "Schematic:Show", ()->
    # SVG.attrs g, opacity: 0
    Tween1 1, -1, 0.7, tick
    Control.panelShowing = false
  
  Reaction "Schematic:Hide", ()->
    # SVG.attrs g, opacity: 1
    Tween1 -1, 1, 0.7, tick
    Control.panelShowing = true
  
  Reaction "ScopeReady", ()->
    Resize resize
    Make "ControlsReady"
  
  Make "Control", Control
