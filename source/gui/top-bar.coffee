Take ["Component", "PointerInput", "Reaction", "Resize", "SVG", "TRS"], (Component, PointerInput, Reaction, Resize, SVG, TRS)->
  topBarHeight = 48
  buttonPad = 30
  iconPad = 6
  
  requested = ["Menu", "Settings"] # We always include the Menu button
  instances = {}
  offsetX = 0
  
  
  topBar = SVG.create "g", SVG.root, class: "TopBar"
  bg = SVG.create "rect", topBar, height: 48, fill: "url(#TopBarGradient)"
  SVG.createGradient "TopBarGradient", false, "#35488d", "#5175bd", "#35488d"
  container = TRS SVG.create "g", topBar, class: "Elements"
  
  
  TopBar = (args...)->
    # This is used by TopBar definitions
    if typeof args[1] is "object"
      Component.make "TopBar", args...
    
    # Called by, most likely, the setup function in the content creator's "root" symbol
    else
      requested.push args...
  
  TopBar.height = topBarHeight

  
  Reaction "ScopeReady", ()->
    definitions = Component.take "TopBar"
    construct i, name, definitions[name] for name, i in requested
    Resize resize
  
  Take "ControlsReady", ()->
    SVG.append SVG.root, topBar # Put the topbar on top of the Control Panel
  
  resize = ()->
    SVG.attrs bg, width: window.innerWidth
    TRS.move container, window.innerWidth/2 - offsetX/2
    instance.api.resize?() for instance in instances
    Make "TopBarReady" unless Take "TopBarReady"
  
  
  construct = (i, name, api)->
    throw "Unknown TopBar button name: #{name}" unless api?
    
    source = document.getElementById(name.toLowerCase())
    throw "TopBar icon not found for id: ##{name}" if not source?
    
    api.element = TRS SVG.create "g", container, class: "Element", ui: true
    instances[name] = element:api.element, i:i, name:name, api:api
    
    # The api can disable these by setting the property to false, or providing its own values
    api.bg ?= SVG.create "rect", api.element, class: "BG", height: topBarHeight
    api.icon ?= TRS SVG.clone source, api.element
    api.text ?= TRS SVG.create "text", api.element, "font-size": 14, fill: "#FFF", textContent: api.label or name.toUpperCase()
    
    iconRect = api.icon.getBoundingClientRect()
    textRect = api.text.getBoundingClientRect()
    iconScale = Math.min (topBarHeight - iconPad*2)/iconRect.width, (topBarHeight - iconPad*2)/iconRect.height
    iconX = buttonPad
    iconY = topBarHeight/2 - iconRect.height*iconScale/2
    textX = buttonPad + iconRect.width*iconScale + iconPad
    buttonWidth = textX + textRect.width + buttonPad
    TRS.abs api.icon, x:iconX, y:iconY, scale: iconScale
    TRS.move api.text, textX, topBarHeight/2 + textRect.height/2 - 3
    SVG.attrs api.bg, width: buttonWidth
    TRS.move api.element, offsetX
    offsetX += buttonWidth
    api.setup? api.element
    PointerInput.addClick api.element, api.click if api.click?
  
  
  Make "TopBar", TopBar
